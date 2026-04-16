from django.db import models

# Create your models here.
from django.db import models
from django.core.validators import FileExtensionValidator
from imagekit.models import ImageSpecField
from imagekit.processors import ResizeToFill, SmartResize
from accounts.models import User
from accounts.models import User
import uuid

class AcademicYear(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=50)
    start_date = models.DateField()
    end_date = models.DateField()
    is_current = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-start_date']
    
    def __str__(self):
        return self.name
    
    def save(self, *args, **kwargs):
        if self.is_current:
            AcademicYear.objects.filter(is_current=True).update(is_current=False)
        super().save(*args, **kwargs)

class YearLevel(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=20)
    display_order = models.IntegerField(default=0)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['display_order']
    
    def __str__(self):
        return self.name

class ClassGroup(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    year_level = models.ForeignKey(YearLevel, on_delete=models.CASCADE, related_name='classes')
    name = models.CharField(max_length=50)
    academic_year = models.ForeignKey(AcademicYear, on_delete=models.CASCADE, related_name='classes')
    #class_teacher = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='classes_taught')
    is_active = models.BooleanField(default=True)
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['year_level__display_order', 'name']
    
    def __str__(self):
        return f"{self.year_level.name} - {self.name} ({self.academic_year})"

class Diocese(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=100, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return self.name

class State(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=100, unique=True)
    
    def __str__(self):
        return self.name

class Student(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='student_profile')
    registration_number = models.CharField(max_length=50, unique=True)
    
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)
    other_names = models.CharField(max_length=100, blank=True)
    date_of_birth = models.DateField(null=True, blank=True)
    
    diocese = models.ForeignKey(Diocese, on_delete=models.SET_NULL, null=True, blank=True)
    hometown = models.CharField(max_length=100, blank=True)
    state_of_origin = models.ForeignKey(State, on_delete=models.SET_NULL, null=True, blank=True)
    
    current_class = models.ForeignKey(ClassGroup, on_delete=models.SET_NULL, null=True, blank=True, related_name='students')
    enrollment_date = models.DateField(auto_now_add=True)
    
    profile_photo = models.ImageField(
        upload_to='students/photos/%Y/%m/',
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
    
    profile_photo_small = ImageSpecField(
        source='profile_photo',
        processors=[SmartResize(200, 200)],
        format='JPEG',
        options={'quality': 85}
    )
    
    profile_photo_medium = ImageSpecField(
        source='profile_photo',
        processors=[SmartResize(400, 400)],
        format='JPEG',
        options={'quality': 90}
    )
    
    additional_photos = models.ManyToManyField('Photo', blank=True, related_name='students')
    
    is_graduated = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    personal_notes = models.TextField(blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        indexes = [
            models.Index(fields=['registration_number']),
            models.Index(fields=['first_name', 'last_name']),
        ]
        ordering = ['last_name', 'first_name']
    
    def __str__(self):
        return f"{self.registration_number} - {self.last_name} {self.first_name}"
    
    @property
    def full_name(self):
        parts = [self.first_name, self.last_name]
        if self.other_names:
            parts.append(self.other_names)
        return ' '.join(parts)
    
    def save(self, *args, **kwargs):
        if not self.registration_number and self.user:
            self.registration_number = self.user.registration_number
        super().save(*args, **kwargs)

class Photo(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    title = models.CharField(max_length=200, blank=True)
    image = models.ImageField(
        upload_to='additional_photos/%Y/%m/',
        validators=[FileExtensionValidator(['jpg', 'jpeg', 'png'])]
    )
    uploaded_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    uploaded_at = models.DateTimeField(auto_now_add=True)
    
    thumbnail = ImageSpecField(
        source='image',
        processors=[ResizeToFill(150, 150)],
        format='JPEG',
        options={'quality': 80}
    )
    
    medium = ImageSpecField(
        source='image',
        processors=[SmartResize(800, 600)],
        format='JPEG',
        options={'quality': 90}
    )
    
    def __str__(self):
        return self.title or f"Photo {self.id}"
#============================================
#
#============================================
# ============================================
# STAFF MODEL
# ============================================

class Staff(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        #related_name='staff_profile'
        related_name='albums_staff_profile'
    )

    staff_id = models.CharField(max_length=50, unique=True)

    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)
    other_names = models.CharField(max_length=100, blank=True)

    position = models.CharField(max_length=200)
    department = models.CharField(max_length=200, blank=True)
    diocese = models.ForeignKey(Diocese, on_delete=models.SET_NULL, null=True, blank=True)

    work_email = models.EmailField(blank=True)
    work_phone = models.CharField(max_length=20, blank=True)

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

    bio = models.TextField(blank=True)

    is_active = models.BooleanField(default=True)

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