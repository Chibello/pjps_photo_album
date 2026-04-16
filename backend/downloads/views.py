from django.shortcuts import render

# Create your views here.
import hashlib
import os
from django.shortcuts import render, get_object_or_404
from django.http import FileResponse, Http404
from django.conf import settings
from django.utils import timezone
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from .models import AppVersion, AppFile, DownloadStat

def download_page(request):
    """Render the app download page"""
    versions = AppVersion.objects.filter(is_active=True).select_related().order_by('platform')
    
    context = {
        'versions': versions,
        'site_url': request.build_absolute_uri('/')[:-1],
    }
    return render(request, 'downloads/download_page.html', context)

def download_file(request, file_id):
    """Serve the app file for download"""
    app_file = get_object_or_404(AppFile, id=file_id)
    
    # Record download
    DownloadStat.objects.create(
        app_file=app_file,
        ip_address=request.META.get('REMOTE_ADDR'),
        user_agent=request.META.get('HTTP_USER_AGENT', ''),
    )
    
    # Increment download count
    app_file.download_count += 1
    app_file.save()
    
    # Serve file
    file_path = app_file.file.path
    if os.path.exists(file_path):
        response = FileResponse(open(file_path, 'rb'), as_attachment=True)
        response['Content-Disposition'] = f'attachment; filename="{app_file.filename}"'
        return response
    else:
        raise Http404("File not found")

@api_view(['GET'])
@permission_classes([AllowAny])
def get_app_versions(request):
    """API endpoint for app to check for updates"""
    platform = request.query_params.get('platform')
    current_version = request.query_params.get('version')
    
    versions = AppVersion.objects.filter(is_active=True)
    if platform:
        versions = versions.filter(platform=platform)
    
    data = []
    for version in versions:
        files = []
        for file in version.files.all():
            files.append({
                'id': str(file.id),
                'filename': file.filename,
                'file_size': file.file_size,
                'download_url': request.build_absolute_uri(f'/downloads/file/{file.id}/'),
            })
        
        data.append({
            'id': str(version.id),
            'platform': version.platform,
            'version': version.version,
            'build_number': version.build_number,
            'release_notes': version.release_notes,
            'is_mandatory': version.is_mandatory,
            'files': files,
            'created_at': version.created_at.isoformat(),
        })
    
    return Response(data)
