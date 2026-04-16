from django.db import models

# Create your models here.
from django.db import models
import os
import uuid

class AppVersion(models.Model):
    PLATFORM_CHOICES = [
        ('android', 'Android'),
        ('ios', 'iOS'),
        ('windows', 'Windows'),
        ('macos', 'macOS'),
        ('linux', 'Linux'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    platform = models.CharField(max_length=20, choices=PLATFORM_CHOICES)
    version = models.CharField(max_length=20)
    build_number = models.CharField(max_length=20)
    release_notes = models.TextField(blank=True)
    is_active = models.BooleanField(default=True)
    is_mandatory = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
        unique_together = ['platform', 'version']
    
    def __str__(self):
        return f"{self.platform} - v{self.version}"

class AppFile(models.Model):
    app_version = models.ForeignKey(AppVersion, on_delete=models.CASCADE, related_name='files')
    file = models.FileField(upload_to='apps/%Y/%m/')
    filename = models.CharField(max_length=255)
    file_size = models.BigIntegerField()
    md5_checksum = models.CharField(max_length=32, blank=True)
    download_count = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return self.filename
    
    def save(self, *args, **kwargs):
        if self.file and not self.file_size:
            self.file_size = self.file.size
        super().save(*args, **kwargs)

class DownloadStat(models.Model):
    app_file = models.ForeignKey(AppFile, on_delete=models.CASCADE)
    ip_address = models.GenericIPAddressField()
    user_agent = models.TextField()
    downloaded_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-downloaded_at']
