from django.shortcuts import render, redirect, get_object_or_404
from django.contrib import messages
from django.contrib.auth.decorators import login_required, user_passes_test
from django.core.mail import send_mail
from django.conf import settings
from django.utils import timezone
from django.core.paginator import Paginator
from django.db.models import Q
from django.contrib.auth import get_user_model, logout
from django.contrib.auth.tokens import default_token_generator
from django.urls import reverse
from django.db import transaction

from django.shortcuts import get_object_or_404, redirect
from django.contrib import messages
from .models import Submission
from django.shortcuts import get_object_or_404, redirect
from django.http import HttpResponse
from .models import Submission


from .models import (
    ApprovalSettings,
    PendingApproval,
    StudentPending,
    StaffPending,
    ApprovalAuditLog
)
from .forms import StudentRegistrationForm, StaffRegistrationForm

User = get_user_model()


# =========================================================
# HELPERS
# =========================================================

def is_admin(user):
    return user.is_authenticated and getattr(user, "is_admin", False)


def prevent_duplicate_registration(reg_number):
    if User.objects.filter(registration_number=reg_number).exists():
        return True
    return False


# =========================================================
# SINGLE SESSION ENFORCEMENT
# =========================================================

def enforce_single_session(request, user):
    """
    Ensures one active session per user.
    If another login exists, terminate it.
    """
    if hasattr(user, "active_session_key") and user.active_session_key:
        from django.contrib.sessions.models import Session
        Session.objects.filter(session_key=user.active_session_key).delete()

    user.active_session_key = request.session.session_key
    user.save(update_fields=["active_session_key"])


# =========================================================
# PUBLIC REGISTRATION
# =========================================================

def student_register(request):

    if request.method == 'POST':
        form = StudentRegistrationForm(request.POST, request.FILES)

        if form.is_valid():
            pending = form.save(commit=False)

            if prevent_duplicate_registration(pending.registration_number):
                messages.error(request, "Registration number already exists.")
                return redirect("registration:student_register")

            pending.user_type = 'STUDENT'
            pending.ip_address = request.META.get('REMOTE_ADDR')
            pending.user_agent = request.META.get('HTTP_USER_AGENT', '')
            pending.save()

            if pending.status == 'PENDING':
                send_admin_notification(pending)

            if pending.status == 'APPROVED':
                send_secure_approval_email(pending)

            return render(request, 'registration/success.html', {
                'submission': pending,
                'auto_approved': pending.status == 'APPROVED'
            })
    else:
        form = StudentRegistrationForm()

    return render(request, 'registration/student_register.html', {
        'form': form,
        'active_tab': 'student',
    })



def staff_register(request):

    if request.method == 'POST':
        form = StaffRegistrationForm(request.POST, request.FILES)

        if form.is_valid():
            pending = form.save(commit=False)

            if prevent_duplicate_registration(pending.registration_number):
                messages.error(request, "Registration number already exists.")
                return redirect("registration:staff_register")

            pending.user_type = 'STAFF'
            pending.ip_address = request.META.get('REMOTE_ADDR')
            pending.user_agent = request.META.get('HTTP_USER_AGENT', '')
            pending.save()

            if pending.status == 'PENDING':
                send_admin_notification(pending)

            if pending.status == 'APPROVED':
                send_secure_approval_email(pending)

            return render(request, 'registration/success.html', {
                'submission': pending,
                'auto_approved': pending.status == 'APPROVED'
            })
    else:
        form = StaffRegistrationForm()

    return render(request, 'registration/staff_register.html', {
        'form': form,
        'active_tab': 'staff',
    })


# =========================================================
# ADMIN BULK APPROVAL
# =========================================================

@login_required
@user_passes_test(is_admin)
def bulk_approve(request):

    if request.method == "POST":
        ids = request.POST.getlist("submission_ids")
        submissions = PendingApproval.objects.filter(id__in=ids, status="PENDING")

        approved_count = 0

        with transaction.atomic():
            for submission in submissions:
                if submission.user_type == "STUDENT":
                    StudentPending.objects.get(id=submission.id).approve(request.user)
                else:
                    StaffPending.objects.get(id=submission.id).approve(request.user)

                ApprovalAuditLog.objects.create(
                    submission=submission,
                    action="APPROVED",
                    performed_by=request.user
                )

                approved_count += 1

        messages.success(request, f"{approved_count} users approved.")

    return redirect("registration:approval_dashboard")


# =========================================================
# AUTO / MANUAL MODE TOGGLE
# =========================================================

@login_required
@user_passes_test(is_admin)
def set_approval_mode(request, mode):

    settings_obj = ApprovalSettings.get_settings()

    if mode in ["AUTOMATIC", "MANUAL", "HYBRID"]:
        settings_obj.mode = mode
        settings_obj.save()
        messages.success(request, f"Approval mode set to {mode}.")

    return redirect("registration:approval_dashboard")


# =========================================================
# SECURE EMAIL (NO PASSWORD SENT)
# =========================================================

def send_secure_approval_email(submission):

    if not submission.email:
        return

    try:
        user = User.objects.get(registration_number=submission.registration_number)
    except User.DoesNotExist:
        return

    token = default_token_generator.make_token(user)
    reset_link = f"{settings.SITE_URL}{reverse('password_reset_confirm', args=[user.pk, token])}"

    subject = "Your Registration Has Been Approved"

    message = f"""
Dear {submission.full_name},

Your account has been approved.

Username: {submission.registration_number}

For security reasons, please set your password using this link:
{reset_link}

PJPS Administration
"""

    send_mail(
        subject,
        message,
        settings.DEFAULT_FROM_EMAIL,
        [submission.email],
        fail_silently=True,
    )


# =========================================================
# ADMIN NOTIFICATION
# =========================================================

def send_admin_notification(submission):

    subject = f"New {submission.user_type} Registration Pending"

    message = f"""
New registration submitted:

Name: {submission.full_name}
Registration Number: {submission.registration_number}
Submitted: {submission.submitted_at}
"""

    send_mail(
        subject,
        message,
        settings.DEFAULT_FROM_EMAIL,
        [settings.ADMIN_EMAIL],
        fail_silently=True,
    )
    

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

#==================================================================
#
#==================================================================
def approve_submission(request, submission_id):
    submission = get_object_or_404(Submission, id=submission_id)
    # logic to approve
    submission.status = 'approved'
    submission.save()
    messages.success(request, "Submission approved successfully!")
    return redirect('registration:index')

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
    
# =========================================================
# SIMPLE APPROVE/REJECT ENDPOINTS (WITHOUT EMAILS)
# =========================================================
def approve_submission(request, submission_id):
    submission = get_object_or_404(Submission, id=submission_id)
    submission.status = 'approved'
    submission.save()
    return HttpResponse(f"Submission {submission_id} approved.")

def reject_submission(request, submission_id):
    submission = get_object_or_404(Submission, id=submission_id)
    submission.status = 'rejected'
    submission.save()
    return HttpResponse(f"Submission {submission_id} rejected.")

#========================================
#index
#========================================


def index(request):
    return render(request, 'index.html')