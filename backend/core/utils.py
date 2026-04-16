import uuid
import os
from django.utils import timezone

def generate_unique_filename(instance, filename):
    """Generate unique filename for uploaded files"""
    ext = filename.split('.')[-1]
    filename = f"{uuid.uuid4().hex}.{ext}"
    return os.path.join('uploads', timezone.now().strftime('%Y/%m/%d'), filename)
