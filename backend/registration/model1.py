
'''
def approve(self, admin_user, password=None):
    """Approve student registration and create user account - MAKES DATA AVAILABLE IN APP"""
    from django.contrib.auth.hashers import make_password
    from django.utils import timezone
    
    # 1. CREATE USER ACCOUNT (used for app login)
    user = User.objects.create_user(
        registration_number=self.registration_number,
        password=self.preferred_password if not password else password,
        first_name=self.full_name.split()[0] if self.full_name.split() else '',
        last_name=' '.join(self.full_name.split()[1:]) if len(self.full_name.split()) > 1 else '',
        email=self.email,
        user_type='STUDENT'
    )
    
    # 2. CREATE STUDENT PROFILE (app will fetch this via API)
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
    
    # 3. COPY PHOTO (app will display this)
    if self.photo:
        student.profile_photo.save(self.photo.name, self.photo, save=True)
    
    # 4. UPDATE STATUS
    self.status = 'APPROVED'
    self.reviewed_at = timezone.now()
    self.reviewed_by = admin_user
    self.save()
    
    return user, student
'''

from django.contrib import admin

# Register your models here.
from django.contrib import admin
from django.contrib import messages
from django.conf import settings
from django.utils import timezone
from .models import ApprovalSettings, StudentPending, StaffPending

@admin.register(ApprovalSettings)
class ApprovalSettingsAdmin(admin.ModelAdmin):
    list_display = ['mode', 'notify_admin_on_auto_approve']
    
    def has_add_permission(self, request):
        # Prevent adding multiple instances
        return False
    
    def has_delete_permission(self, request, obj=None):
        return False
    
    def save_model(self, request, obj, form, change):
        obj.pk = 1
        super().save_model(request, obj, form, change)
        messages.success(request, f"Approval mode changed to {obj.get_mode_display()}")

class ApprovalActionsMixin:
    """Mixin for approval actions in admin"""
    
    def approve_selected(self, request, queryset):
        count = 0
        for item in queryset:
            if item.status == 'PENDING':
                if item.user_type == 'STUDENT':
                    student_pending = StudentPending.objects.get(id=item.id)
                    user, profile = student_pending.approve(request.user)
                else:
                    staff_pending = StaffPending.objects.get(id=item.id)
                    user, profile = staff_pending.approve(request.user)
                count += 1
        
        self.message_user(request, f"{count} submissions approved successfully.")
    approve_selected.short_description = "Approve selected submissions"
    
    def reject_selected(self, request, queryset):
        count = queryset.update(status='REJECTED', reviewed_at=timezone.now(), reviewed_by=request.user)
        self.message_user(request, f"{count} submissions rejected.", level=messages.WARNING)
    reject_selected.short_description = "Reject selected submissions"

@admin.register(StudentPending)
class StudentPendingAdmin(admin.ModelAdmin, ApprovalActionsMixin):
    list_display = ['full_name', 'registration_number', 'status', 'submitted_at', 'auto_approved']
    list_filter = ['status', 'auto_approved', 'diocese', 'year_level']
    search_fields = ['full_name', 'registration_number', 'email']
    actions = ['approve_selected', 'reject_selected']
    
    fieldsets = (
        ('Status', {
            'fields': ('status', 'auto_approved', 'admin_notes')
        }),
        ('Personal Information', {
            'fields': ('full_name', 'registration_number', 'email', 'phone', 'date_of_birth')
        }),
        ('Location', {
            'fields': ('diocese', 'hometown', 'state')
        }),
        ('Academic', {
            'fields': ('year_level', 'previous_school')
        }),
        ('Guardian', {
            'fields': ('guardian_name', 'guardian_phone', 'guardian_email')
        }),
        ('Photo', {
            'fields': ('photo',)
        }),
    )

@admin.register(StaffPending)
class StaffPendingAdmin(admin.ModelAdmin, ApprovalActionsMixin):
    list_display = ['full_name', 'registration_number', 'status', 'submitted_at', 'auto_approved']
    list_filter = ['status', 'auto_approved', 'staff_category']
    search_fields = ['full_name', 'registration_number', 'email']
    actions = ['approve_selected', 'reject_selected']



#######################################################

from django.db import models

# Create your models here.
from django.db import models
from django.contrib.auth import get_user_model
from albums.models import Diocese, State, Student, Staff
import uuid

User = get_user_model()

class PendingApproval(models.Model):
    """Base model for pending approvals"""
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
    
    # Common fields
    full_name = models.CharField(max_length=200)
    email = models.EmailField(blank=True, null=True)
    phone = models.CharField(max_length=20, blank=True)
    
    # Authentication
    registration_number = models.CharField(max_length=50, unique=True)
    preferred_password = models.CharField(max_length=128)  # Will be hashed when approved
    
    # Location
    diocese = models.ForeignKey(Diocese, on_delete=models.SET_NULL, null=True)
    diocese_name = models.CharField(max_length=100, blank=True)  # For custom entries
    hometown = models.CharField(max_length=100)
    state = models.ForeignKey(State, on_delete=models.SET_NULL, null=True)
    state_name = models.CharField(max_length=100, blank=True)  # For custom entries
    
    # Photo
    photo = models.ImageField(upload_to='pending_photos/%Y/%m/', null=True, blank=True)
    
    # Metadata
    submitted_at = models.DateTimeField(auto_now_add=True)
    reviewed_at = models.DateTimeField(null=True, blank=True)
    reviewed_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='reviewed_submissions')
    admin_notes = models.TextField(blank=True, help_text="Notes from admin about this submission")
    
    # For tracking
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    user_agent = models.TextField(blank=True)

    class Meta:
        ordering = ['-submitted_at']
        indexes = [
            models.Index(fields=['status']),
            models.Index(fields=['registration_number']),
            models.Index(fields=['submitted_at']),
        ]

    def __str__(self):
        return f"{self.full_name} - {self.registration_number} ({self.status})"

class StudentPending(PendingApproval):
    """Student-specific pending registration"""
    # Student-specific fields
    date_of_birth = models.DateField(null=True, blank=True)
    year_level = models.CharField(max_length=20, blank=True, help_text="Year 1, Year 2, etc.")
    previous_school = models.CharField(max_length=200, blank=True)
    guardian_name = models.CharField(max_length=200, blank=True)
    guardian_phone = models.CharField(max_length=20, blank=True)
    guardian_email = models.EmailField(blank=True)
    
    class Meta:
        verbose_name = "Pending Student"
        verbose_name_plural = "Pending Students"

    def approve(self, admin_user, password=None):
        """Approve student registration and create user account"""
        from django.contrib.auth.hashers import make_password
        from django.utils import timezone
        
        # Create user
        user = User.objects.create_user(
            registration_number=self.registration_number,
            password=self.preferred_password if not password else password,
            first_name=self.full_name.split()[0] if self.full_name.split() else '',
            last_name=' '.join(self.full_name.split()[1:]) if len(self.full_name.split()) > 1 else '',
            email=self.email,
            user_type='STUDENT'
        )
        
        # Create student profile
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
        
        # Copy photo if exists
        if self.photo:
            student.profile_photo.save(self.photo.name, self.photo, save=True)
        
        # Update pending record
        self.status = 'APPROVED'
        self.reviewed_at = timezone.now()
        self.reviewed_by = admin_user
        self.save()
        
        return user, student

class StaffPending(PendingApproval):
    """Staff-specific pending registration"""
    STAFF_CATEGORY_CHOICES = (
        ('ADMIN', 'Administrative'),
        ('ACADEMIC', 'Academic'),
        ('LIBRARY', 'Library'),
        ('TECHNICAL', 'Technical'),
        ('SUPPORT', 'Support'),
    )
    
    # Staff-specific fields
    staff_category = models.CharField(max_length=20, choices=STAFF_CATEGORY_CHOICES, default='ACADEMIC')
    position = models.CharField(max_length=200)
    department = models.CharField(max_length=200, blank=True)
    qualifications = models.TextField(blank=True)
    years_of_experience = models.IntegerField(null=True, blank=True)
    emergency_contact = models.CharField(max_length=200, blank=True)
    emergency_phone = models.CharField(max_length=20, blank=True)
    
    class Meta:
        verbose_name = "Pending Staff"
        verbose_name_plural = "Pending Staff"

    def approve(self, admin_user, password=None):
        """Approve staff registration and create user account"""
        from django.contrib.auth.hashers import make_password
        from django.utils import timezone
        
        # Create user
        user = User.objects.create_user(
            registration_number=self.registration_number,
            password=self.preferred_password if not password else password,
            first_name=self.full_name.split()[0] if self.full_name.split() else '',
            last_name=' '.join(self.full_name.split()[1:]) if len(self.full_name.split()) > 1 else '',
            email=self.email,
            user_type='STAFF'
        )
        
        # Create staff profile
        from staff.models import Staff
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
        
        # Copy photo if exists
        if self.photo:
            staff.profile_photo.save(self.photo.name, self.photo, save=True)
        
        # Update pending record
        self.status = 'APPROVED'
        self.reviewed_at = timezone.now()
        self.reviewed_by = admin_user
        self.save()
        
        return user, staff

##--------------------------------##

def approve(self, admin_user, password=None):
    """Approve student registration and create user account - MAKES DATA AVAILABLE IN APP"""
    from django.contrib.auth.hashers import make_password
    from django.utils import timezone
    
    # 1. CREATE USER ACCOUNT (used for app login)
    user = User.objects.create_user(
        registration_number=self.registration_number,
        password=self.preferred_password if not password else password,
        first_name=self.full_name.split()[0] if self.full_name.split() else '',
        last_name=' '.join(self.full_name.split()[1:]) if len(self.full_name.split()) > 1 else '',
        email=self.email,
        user_type='STUDENT'
    )
    
    # 2. CREATE STUDENT PROFILE (app will fetch this via API)
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
    
    # 3. COPY PHOTO (app will display this)
    if self.photo:
        student.profile_photo.save(self.photo.name, self.photo, save=True)
    
    # 4. UPDATE STATUS
    self.status = 'APPROVED'
    self.reviewed_at = timezone.now()
    self.reviewed_by = admin_user
    self.save()
    
    return user, student

##-------------------##
from django.db import models
from django.core.mail import send_mail
from django.conf import settings

class ApprovalSettings(models.Model):
    """Global settings for approval system"""
    MODE_CHOICES = (
        ('MANUAL', 'Manual Approval - Admin reviews each'),
        ('AUTOMATIC', 'Automatic Approval - Instant account creation'),
        ('HYBRID', 'Hybrid - Admin chooses per submission'),
    )
    
    mode = models.CharField(max_length=20, choices=MODE_CHOICES, default='MANUAL')
    
    # Automatic approval rules
    auto_approve_domains = models.TextField(
        blank=True,
        help_text="Comma-separated email domains to auto-approve (e.g., @pjps.edu)"
    )
    auto_approve_dioceses = models.ManyToManyField(
        'albums.Diocese', 
        blank=True,
        help_text="Dioceses to auto-approve"
    )
    
    # Notification settings
    notify_admin_on_auto_approve = models.BooleanField(default=True)
    notify_user_on_approval = models.BooleanField(default=True)
    
    # Single instance (singleton pattern)
    class Meta:
        verbose_name = "Approval Settings"
        verbose_name_plural = "Approval Settings"
    
    def save(self, *args, **kwargs):
        # Ensure only one instance exists
        self.pk = 1
        super().save(*args, **kwargs)
    
    @classmethod
    def get_settings(cls):
        obj, created = cls.objects.get_or_create(pk=1)
        return obj
    
    def __str__(self):
        return f"Approval Mode: {self.get_mode_display()}"

class PendingApproval(models.Model):
    # ... existing fields ...
    
    # Add auto-approval tracking
    auto_approved = models.BooleanField(default=False)
    approval_mode_used = models.CharField(max_length=20, null=True, blank=True)
    
    # ... rest of existing code ...

class StudentPending(PendingApproval):
    # ... existing fields ...
    
    def should_auto_approve(self):
        """Check if this submission should be auto-approved"""
        settings = ApprovalSettings.get_settings()
        
        if settings.mode == 'AUTOMATIC':
            return True
        
        if settings.mode == 'HYBRID':
            # Check auto-approval rules
            if self.email and any(
                domain in self.email 
                for domain in settings.auto_approve_domains.split(',') 
                if domain.strip()
            ):
                return True
            
            if self.diocese and self.diocese in settings.auto_approve_dioceses.all():
                return True
        
        return False
