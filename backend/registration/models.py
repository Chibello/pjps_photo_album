from django.db import models, transaction
from django.contrib.auth import get_user_model
from django.utils import timezone
from django.conf import settings
from albums.models import Diocese, State, Student, Staff
import uuid

User = get_user_model()


# =========================================================
# APPROVAL SETTINGS (Singleton)
# =========================================================

class ApprovalSettings(models.Model):
    MODE_CHOICES = (
        ('MANUAL', 'Manual Approval - Admin reviews each'),
        ('AUTOMATIC', 'Automatic Approval - Instant account creation'),
        ('HYBRID', 'Hybrid - Admin chooses per submission'),
    )

    mode = models.CharField(max_length=20, choices=MODE_CHOICES, default='MANUAL')

    auto_approve_domains = models.TextField(
        blank=True,
        help_text="Comma-separated email domains (e.g., @pjps.edu)"
    )

    auto_approve_dioceses = models.ManyToManyField(
        Diocese,
        blank=True
    )

    notify_admin_on_auto_approve = models.BooleanField(default=True)
    notify_user_on_approval = models.BooleanField(default=True)

    class Meta:
        verbose_name = "Approval Settings"
        verbose_name_plural = "Approval Settings"

    def save(self, *args, **kwargs):
        self.pk = 1
        super().save(*args, **kwargs)

    @classmethod
    def get_settings(cls):
        obj, _ = cls.objects.get_or_create(pk=1)
        return obj

    def __str__(self):
        return f"Approval Mode: {self.get_mode_display()}"


# =========================================================
# BASE PENDING MODEL
# =========================================================

class PendingApproval(models.Model):

    STATUS_CHOICES = (
        ('PENDING', 'Pending Review'),
        ('APPROVED', 'Approved'),
        ('REJECTED', 'Rejected'),
        ('NEEDS_EDIT', 'Needs Editing'),
    )

    USER_TYPE_CHOICES = (
        ('STUDENT', 'Student'),
        ('STAFF', 'Staff'),
    )

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user_type = models.CharField(max_length=10, choices=USER_TYPE_CHOICES)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='PENDING')

    full_name = models.CharField(max_length=200)
    email = models.EmailField(blank=True, null=True)
    phone = models.CharField(max_length=20, blank=True)

    registration_number = models.CharField(max_length=50, unique=True)
    preferred_password = models.CharField(max_length=128)

    diocese = models.ForeignKey(Diocese, on_delete=models.SET_NULL, null=True)
    hometown = models.CharField(max_length=100)
    state = models.ForeignKey(State, on_delete=models.SET_NULL, null=True)

    photo = models.ImageField(upload_to='pending_photos/%Y/%m/', null=True, blank=True)

    submitted_at = models.DateTimeField(auto_now_add=True)
    reviewed_at = models.DateTimeField(null=True, blank=True)
    reviewed_by = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='reviewed_submissions'
    )

    admin_notes = models.TextField(blank=True)

    ip_address = models.GenericIPAddressField(null=True, blank=True)
    user_agent = models.TextField(blank=True)

    auto_approved = models.BooleanField(default=False)
    approval_mode_used = models.CharField(max_length=20, null=True, blank=True)

    class Meta:
        ordering = ['-submitted_at']
        indexes = [
            models.Index(fields=['status']),
            models.Index(fields=['registration_number']),
            models.Index(fields=['submitted_at']),
        ]

    def __str__(self):
        return f"{self.full_name} - {self.registration_number} ({self.status})"

    # -----------------------------------------------------
    # AUTO APPROVAL CHECK
    # -----------------------------------------------------

    def should_auto_approve(self):
        settings = ApprovalSettings.get_settings()

        if settings.mode == 'AUTOMATIC':
            return True

        if settings.mode == 'HYBRID':

            if self.email:
                domains = [
                    d.strip() for d in settings.auto_approve_domains.split(',')
                    if d.strip()
                ]
                if any(self.email.endswith(domain) for domain in domains):
                    return True

            if self.diocese and self.diocese in settings.auto_approve_dioceses.all():
                return True

        return False


# =========================================================
# STUDENT PENDING
# =========================================================

class StudentPending(PendingApproval):

    date_of_birth = models.DateField(null=True, blank=True)
    year_level = models.CharField(max_length=20, blank=True)
    previous_school = models.CharField(max_length=200, blank=True)
    guardian_name = models.CharField(max_length=200, blank=True)
    guardian_phone = models.CharField(max_length=20, blank=True)
    guardian_email = models.EmailField(blank=True)

    class Meta:
        verbose_name = "Pending Student"
        verbose_name_plural = "Pending Students"

    # 🔥 AUTO APPROVAL TRIGGER
    def save(self, *args, **kwargs):
        is_new = self._state.adding
        super().save(*args, **kwargs)

        if is_new and self.status == 'PENDING':
            if self.should_auto_approve():
                self._auto_approve()

    def _auto_approve(self):
        if self.status != 'PENDING':
            return
        self.approve(admin_user=None)

    @transaction.atomic
    def approve(self, admin_user, password=None):

        if self.status == 'APPROVED':
            return

        user = User.objects.create_user(
            registration_number=self.registration_number,
            password=password or self.preferred_password,
            first_name=self.full_name.split()[0] if self.full_name.split() else '',
            last_name=' '.join(self.full_name.split()[1:]) if len(self.full_name.split()) > 1 else '',
            email=self.email,
            user_type='STUDENT'
        )

        student = Student.objects.create(
            user=user,
            registration_number=self.registration_number,
            first_name=user.first_name,
            last_name=user.last_name,
            other_names='',
            date_of_birth=self.date_of_birth,
            diocese=self.diocese,
            hometown=self.hometown,
            state_of_origin=self.state,
            personal_notes=f"Registered via web form on {self.submitted_at.date()}"
        )

        if self.photo:
            student.profile_photo.save(self.photo.name, self.photo, save=True)

        self.status = 'APPROVED'
        self.reviewed_at = timezone.now()
        self.reviewed_by = admin_user
        self.auto_approved = admin_user is None
        self.approval_mode_used = ApprovalSettings.get_settings().mode

        super().save(update_fields=[
            'status',
            'reviewed_at',
            'reviewed_by',
            'auto_approved',
            'approval_mode_used'
        ])

        return user, student


# =========================================================
# STAFF PENDING
# =========================================================

class StaffPending(PendingApproval):

    STAFF_CATEGORY_CHOICES = (
        ('ADMIN', 'Administrative'),
        ('ACADEMIC', 'Academic'),
        ('LIBRARY', 'Library'),
        ('TECHNICAL', 'Technical'),
        ('SUPPORT', 'Support'),
    )

    staff_category = models.CharField(
        max_length=20,
        choices=STAFF_CATEGORY_CHOICES,
        default='ACADEMIC'
    )

    position = models.CharField(max_length=200)
    department = models.CharField(max_length=200, blank=True)
    qualifications = models.TextField(blank=True)
    years_of_experience = models.IntegerField(null=True, blank=True)
    emergency_contact = models.CharField(max_length=200, blank=True)
    emergency_phone = models.CharField(max_length=20, blank=True)

    class Meta:
        verbose_name = "Pending Staff"
        verbose_name_plural = "Pending Staff"

    def save(self, *args, **kwargs):
        is_new = self._state.adding
        super().save(*args, **kwargs)

        if is_new and self.status == 'PENDING':
            if self.should_auto_approve():
                self._auto_approve()

    def _auto_approve(self):
        if self.status != 'PENDING':
            return
        self.approve(admin_user=None)

    @transaction.atomic
    def approve(self, admin_user, password=None):

        if self.status == 'APPROVED':
            return

        user = User.objects.create_user(
            registration_number=self.registration_number,
            password=password or self.preferred_password,
            first_name=self.full_name.split()[0] if self.full_name.split() else '',
            last_name=' '.join(self.full_name.split()[1:]) if len(self.full_name.split()) > 1 else '',
            email=self.email,
            user_type='STAFF'
        )

        staff = Staff.objects.create(
            user=user,
            staff_id=self.registration_number,
            first_name=user.first_name,
            last_name=user.last_name,
            other_names='',
            position=self.position,
            work_email=self.email,
            work_phone=self.phone or '',
            bio=f"Registered via web form on {self.submitted_at.date()}\nQualifications: {self.qualifications}"
        )

        if self.photo:
            staff.profile_photo.save(self.photo.name, self.photo, save=True)

        self.status = 'APPROVED'
        self.reviewed_at = timezone.now()
        self.reviewed_by = admin_user
        self.auto_approved = admin_user is None
        self.approval_mode_used = ApprovalSettings.get_settings().mode

        super().save(update_fields=[
            'status',
            'reviewed_at',
            'reviewed_by',
            'auto_approved',
            'approval_mode_used'
        ])

        return user, staff

# =========================================================
# APPROVAL AUDIT LOG
# =========================================================

class ApprovalAuditLog(models.Model):

    ACTION_CHOICES = (
        ('APPROVED', 'Approved'),
        ('REJECTED', 'Rejected'),
        ('AUTO_APPROVED', 'Auto Approved'),
        ('REQUEST_CHANGES', 'Requested Changes'),
    )

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    submission = models.ForeignKey(
        PendingApproval,
        on_delete=models.CASCADE,
        related_name='audit_logs'
    )

    action = models.CharField(max_length=20, choices=ACTION_CHOICES)

    performed_by = models.ForeignKey(
        User,
        null=True,
        blank=True,
        on_delete=models.SET_NULL
    )

    notes = models.TextField(blank=True)

    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.submission.registration_number} - {self.action}"
    
#=========================================================
#
#=========================================================

class Submission(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    status = models.CharField(max_length=50, default='pending')  # 'pending', 'approved', 'rejected'
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title