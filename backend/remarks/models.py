from django.db import models

# Create your models here.
from django.db import models
from django.contrib.contenttypes.fields import GenericForeignKey, GenericRelation
from django.contrib.contenttypes.models import ContentType
from accounts.models import User
import uuid

class RemarkBook(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    content_type = models.ForeignKey(ContentType, on_delete=models.CASCADE)
    object_id = models.UUIDField()
    content_object = GenericForeignKey('content_type', 'object_id')
    
    title = models.CharField(max_length=200, default="Remarks")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        unique_together = ('content_type', 'object_id')
    
    def __str__(self):
        return f"Remark Book for {self.content_object}"

class Remark(models.Model):
    REMARK_TYPES = (
        ('GENERAL', 'General Note'),
        ('ACADEMIC', 'Academic'),
        ('BEHAVIORAL', 'Behavioral'),
        ('ACHIEVEMENT', 'Achievement'),
        ('ATTENDANCE', 'Attendance'),
        ('OTHER', 'Other'),
    )
    
    VISIBILITY = (
        ('PRIVATE', 'Private'),
        ('INTERNAL', 'Internal'),
        ('PUBLIC', 'Public'),
    )
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    remark_book = models.ForeignKey(RemarkBook, on_delete=models.CASCADE, related_name='remarks')
    
    author = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='authored_remarks')
    remark_type = models.CharField(max_length=20, choices=REMARK_TYPES, default='GENERAL')
    visibility = models.CharField(max_length=20, choices=VISIBILITY, default='INTERNAL')
    
    title = models.CharField(max_length=200)
    content = models.TextField()
    
    attachment = models.FileField(upload_to='remark_attachments/%Y/%m/', null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.title} - {self.created_at.date()}"

class RemarkComment(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    remark = models.ForeignKey(Remark, on_delete=models.CASCADE, related_name='comments')
    author = models.ForeignKey(User, on_delete=models.CASCADE)
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['created_at']
    
    def __str__(self):
        return f"Comment by {self.author} on {self.created_at.date()}"
