from django.shortcuts import render, redirect, get_object_or_404
from django.contrib import messages
from django.contrib.auth.decorators import login_required, user_passes_test
from django.core.mail import send_mail
from django.conf import settings
from django.utils import timezone
from django.core.paginator import Paginator
from django.db.models import Q

from .models import (
    ApprovalSettings,
    PendingApproval,
    StudentPending,
    StaffPending
)
from .forms import StudentRegistrationForm, StaffRegistrationForm


# =========================================================
# HELPERS
# =========================================================

def is_admin(user):
    return user.is_authenticated and getattr(user, "is_admin", False)


# =========================================================
# PUBLIC VIEWS
# =========================================================

def index(request):
    return render(request, 'registration/index.html', {
        'active_tab': 'index'
    })


def student_register(request):
    """
    Student registration.
    Auto-approval (if enabled) is handled inside the model.
    """
    if request.method == 'POST':
        form = StudentRegistrationForm(request.POST, request.FILES)
        if form.is_valid():
            pending = form.save(commit=False)
            pending.user_type = 'STUDENT'
            pending.ip_address = request.META.get('REMOTE_ADDR')
            pending.user_agent = request.META.get('HTTP_USER_AGENT', '')
            pending.save()  # 🔥 This may auto-approve immediately

            # If still pending → notify admin
            if pending.status == 'PENDING':
                send_admin_notification(pending)

            # If auto-approved → notify user
            if pending.status == 'APPROVED':
                if ApprovalSettings.get_settings().notify_user_on_approval:
                    send_approval_email(pending)

            return render(request, 'registration/success.html', {
                'submission': pending,
                'auto_approved': pending.status == 'APPROVED'
            })
    else:
        form = StudentRegistrationForm()

    return render(request, 'registration/student_register.html', {
        'form': form,
        'active_tab': 'student',
        'settings': ApprovalSettings.get_settings()
    })


def staff_register(request):
    """
    Staff registration.
    Auto-approval handled inside model.
    """
    if request.method == 'POST':
        form = StaffRegistrationForm(request.POST, request.FILES)
        if form.is_valid():
            pending = form.save(commit=False)
            pending.user_type = 'STAFF'
            pending.ip_address = request.META.get('REMOTE_ADDR')
            pending.user_agent = request.META.get('HTTP_USER_AGENT', '')
            pending.save()

            if pending.status == 'PENDING':
                send_admin_notification(pending)

            if pending.status == 'APPROVED':
                if ApprovalSettings.get_settings().notify_user_on_approval:
                    send_approval_email(pending)

            return render(request, 'registration/success.html', {
                'submission': pending,
                'auto_approved': pending.status == 'APPROVED'
            })
    else:
        form = StaffRegistrationForm()

    return render(request, 'registration/staff_register.html', {
        'form': form,
        'active_tab': 'staff',
        'settings': ApprovalSettings.get_settings()
    })


# =========================================================
# ADMIN DASHBOARD
# =========================================================

@login_required
@user_passes_test(is_admin)
def approval_dashboard(request):

    status_filter = request.GET.get('status', '')
    type_filter = request.GET.get('type', '')
    search_query = request.GET.get('search', '')

    submissions = PendingApproval.objects.all()

    if status_filter:
        submissions = submissions.filter(status=status_filter)

    if type_filter:
        submissions = submissions.filter(user_type=type_filter)

    if search_query:
        submissions = submissions.filter(
            Q(full_name__icontains=search_query) |
            Q(registration_number__icontains=search_query)
        )

    submissions = submissions.order_by('-submitted_at')

    paginator = Paginator(submissions, 20)
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)

    today = timezone.now().date()

    context = {
        'submissions': page_obj,
        'pending_students': StudentPending.objects.filter(status='PENDING').count(),
        'pending_staff': StaffPending.objects.filter(status='PENDING').count(),
        'approved_today': PendingApproval.objects.filter(
            status='APPROVED',
            reviewed_at__date=today
        ).count(),
        'total_registered': PendingApproval.objects.filter(
            status='APPROVED'
        ).count(),
        'current_mode': ApprovalSettings.get_settings().get_mode_display(),
        'settings': ApprovalSettings.get_settings(),
        'status_filter': status_filter,
        'type_filter': type_filter,
        'search_query': search_query,
    }

    return render(request, 'registration/admin/approval_dashboard.html', context)


# =========================================================
# ADMIN ACTIONS
# =========================================================

@login_required
@user_passes_test(is_admin)
def review_submission(request, submission_id):

    submission = get_object_or_404(PendingApproval, id=submission_id)

    if request.method == 'POST':
        action = request.POST.get('action')

        # APPROVE
        if action == 'approve':

            if submission.user_type == 'STUDENT':
                student_pending = StudentPending.objects.get(id=submission_id)
                student_pending.approve(request.user)

            elif submission.user_type == 'STAFF':
                staff_pending = StaffPending.objects.get(id=submission_id)
                staff_pending.approve(request.user)

            send_approval_email(submission)
            messages.success(request, f'{submission.full_name} approved successfully.')

            return redirect('registration:approval_dashboard')

        # REJECT
        elif action == 'reject':
            reason = request.POST.get('reason', '')
            submission.status = 'REJECTED'
            submission.reviewed_at = timezone.now()
            submission.reviewed_by = request.user
            submission.admin_notes = reason
            submission.save()

            send_rejection_email(submission, reason)
            messages.warning(request, f'{submission.full_name} rejected.')

            return redirect('registration:approval_dashboard')

        # REQUEST CHANGES
        elif action == 'request_changes':
            notes = request.POST.get('admin_notes', '')
            submission.status = 'NEEDS_EDIT'
            submission.admin_notes = notes
            submission.save()

            send_changes_requested_email(submission, notes)
            messages.info(request, f'Changes requested for {submission.full_name}.')

            return redirect('registration:approval_dashboard')

    return render(request, 'registration/admin/review_submission.html', {
        'submission': submission
    })


# =========================================================
# EMAILS
# =========================================================

def send_admin_notification(submission):

    subject = f'New {submission.user_type} Registration Pending Approval'

    message = f"""
A new registration has been submitted.

Name: {submission.full_name}
Registration Number: {submission.registration_number}
Type: {submission.user_type}
Submitted: {submission.submitted_at}

Review at: {settings.SITE_URL}/registration/admin/dashboard/
"""

    send_mail(
        subject,
        message,
        settings.DEFAULT_FROM_EMAIL,
        [settings.ADMIN_EMAIL],
        fail_silently=True,
    )


def send_approval_email(submission):

    if not submission.email:
        return

    subject = "Your PJPS Registration Has Been Approved"

    message = f"""
Dear {submission.full_name},

Your registration has been approved.

Username: {submission.registration_number}

You can now login to the PJPS Photo Album app.

Best regards,
PJPS Administration
"""

    send_mail(
        subject,
        message,
        settings.DEFAULT_FROM_EMAIL,
        [submission.email],
        fail_silently=True,
    )


def send_rejection_email(submission, reason):

    if not submission.email:
        return

    subject = "Update on Your Registration"

    message = f"""
Dear {submission.full_name},

Your registration was not approved.

Reason:
{reason}

If you believe this is an error, contact administration.

PJPS Administration
"""

    send_mail(
        subject,
        message,
        settings.DEFAULT_FROM_EMAIL,
        [submission.email],
        fail_silently=True,
    )


def send_changes_requested_email(submission, notes):

    if not submission.email:
        return

    subject = "Action Required: Update Your Registration"

    message = f"""
Dear {submission.full_name},

The administrator has requested changes:

{notes}

Please resubmit your registration.

PJPS Administration
"""

    send_mail(
        subject,
        message,
        settings.DEFAULT_FROM_EMAIL,
        [submission.email],
        fail_silently=True,
    )