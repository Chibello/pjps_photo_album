from django.db import models

# Create your models here.
from django.db import models
from django.core.validators import FileExtensionValidator, EmailValidator
from imagekit.models import ImageSpecField
from imagekit.processors import ResizeToFill, SmartResize
from accounts.models import User
import uuid

class Department(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=100, unique=True)
    code = models.CharField(max_length=20, unique=True)
    description = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['name']
    
    def __str__(self):
        return f"{self.name} ({self.code})"

class StaffCategory(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=50, unique=True)
    description = models.TextField(blank=True)
    display_order = models.IntegerField(default=0)
    
    class Meta:
        verbose_name_plural = "Staff categories"
        ordering = ['display_order', 'name']
    
    def __str__(self):
        return self.name

class Staff(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='staff_profile')
    staff_id = models.CharField(max_length=50, unique=True)
    
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)
    other_names = models.CharField(max_length=100, blank=True)
    date_of_birth = models.DateField(null=True, blank=True)
    related_name='albums_staff_profile'
    
    category = models.ForeignKey(StaffCategory, on_delete=models.SET_NULL, null=True, related_name='staff_members')
    department = models.ForeignKey(Department, on_delete=models.SET_NULL, null=True, related_name='staff_members')
    position = models.CharField(max_length=200)
    employment_date = models.DateField()
    
    work_email = models.EmailField(validators=[EmailValidator()], unique=True)
    work_phone = models.CharField(max_length=20)
    office_location = models.CharField(max_length=200, blank=True)
    office_hours = models.TextField(blank=True)
    
    bio = models.TextField(blank=True)
    qualifications = models.TextField(blank=True)
    responsibilities = models.TextField(blank=True)
    
    profile_photo = models.ImageField(
        upload_to='staff/photos/%Y/%m/',
        validators=[FileExtensionValidator(['jpg', 'jpeg', 'png'])],
        null=True,
        blank=True
    )
    
    profile_photo_thumbnail = ImageSpecField(
        source='profile_photo',
        processors=[ResizeToFill(100, 100)],
        format='JPEG',
        options={'quality': 80}
    )
    
    profile_photo_medium = ImageSpecField(
        source='profile_photo',
        processors=[SmartResize(300, 300)],
        format='JPEG',
        options={'quality': 85}
    )
    
    is_active = models.BooleanField(default=True)
    is_current_staff = models.BooleanField(default=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        indexes = [
            models.Index(fields=['staff_id']),
            models.Index(fields=['first_name', 'last_name']),
        ]
        ordering = ['last_name', 'first_name']
    
    def __str__(self):
        return f"{self.staff_id} - {self.last_name} {self.first_name}"
    
    @property
    def full_name(self):
        parts = [self.first_name, self.last_name]
        if self.other_names:
            parts.append(self.other_names)
        return ' '.join(parts)
    
    def save(self, *args, **kwargs):
        if not self.staff_id and self.user:
            self.staff_id = self.user.registration_number
        super().save(*args, **kwargs)

class AdministrativeStaff(models.Model):
    staff = models.OneToOneField(Staff, on_delete=models.CASCADE, primary_key=True, related_name='admin_details')
    admin_role = models.CharField(max_length=100)
    reports_to = models.ForeignKey('self', on_delete=models.SET_NULL, null=True, blank=True)
    manages_department = models.ForeignKey(Department, on_delete=models.SET_NULL, null=True, blank=True)
    
    class Meta:
        verbose_name_plural = "Administrative staff"
    
    def __str__(self):
        return f"{self.staff.full_name} - {self.admin_role}"

class LibraryStaff(models.Model):
    LIBRARY_SECTIONS = [
        ('CIRCULATION', 'Circulation Desk'),
        ('REFERENCE', 'Reference Section'),
        ('CATALOGING', 'Cataloging'),
        ('DIGITAL', 'Digital Library'),
        ('ARCHIVES', 'Archives'),
        ('PERIODICALS', 'Periodicals'),
        ('ADMIN', 'Library Administration'),
    ]
    
    staff = models.OneToOneField(Staff, on_delete=models.CASCADE, primary_key=True, related_name='library_details')
    library_section = models.CharField(max_length=50, choices=LIBRARY_SECTIONS)
    librarian_rank = models.CharField(max_length=100)
    specialization = models.CharField(max_length=200, blank=True)
    
    def __str__(self):
        return f"{self.staff.full_name} - {self.get_library_section_display()}"
