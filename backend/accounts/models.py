from django.db import models

# Create your models here.
from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.db import models
from django.utils import timezone
import uuid

class UserManager(BaseUserManager):
    def create_user(self, registration_number, password=None, **extra_fields):
        if not registration_number:
            raise ValueError('Registration Number is required')
        
        user = self.model(registration_number=registration_number, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user
    
    def create_superuser(self, registration_number, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_admin', True)
        extra_fields.setdefault('user_type', 'ADMIN')
        
        return self.create_user(registration_number, password, **extra_fields)

class User(AbstractUser):
    username = None
    USER_TYPES = (
        ('STUDENT', 'Student'),
        ('STAFF', 'Staff'),
        ('ADMIN', 'Administrator'),
    )
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    registration_number = models.CharField(max_length=50, unique=True)
    email = models.EmailField(unique=True, null=True, blank=True)
    user_type = models.CharField(max_length=20, choices=USER_TYPES, default='STUDENT')
    current_session_token = models.CharField(max_length=255, null=True, blank=True)
    last_login_ip = models.GenericIPAddressField(null=True, blank=True)
    is_active = models.BooleanField(default=True)
    is_admin = models.BooleanField(default=False)
    password_changed_at = models.DateTimeField(default=timezone.now)
    
    USERNAME_FIELD = 'registration_number'
    REQUIRED_FIELDS = []
    
    objects = UserManager()
    
    class Meta:
        db_table = 'accounts_user'
        indexes = [
            models.Index(fields=['registration_number']),
            models.Index(fields=['email']),
        ]
    
    def __str__(self):
        return f"{self.registration_number} - {self.get_full_name()}"

class LoginHistory(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='login_history')
    login_time = models.DateTimeField(auto_now_add=True)
    ip_address = models.GenericIPAddressField()
    device_info = models.TextField(blank=True)
    session_token = models.CharField(max_length=255)
    
    class Meta:
        ordering = ['-login_time']
        
    def __str__(self):
        return f"{self.user.registration_number} - {self.login_time}"
