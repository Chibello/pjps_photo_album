from django.contrib import admin

# Register your models here.
from django.contrib import admin
from .models import AppVersion, AppFile, DownloadStat

class AppFileInline(admin.TabularInline):
    model = AppFile
    extra = 1

@admin.register(AppVersion)
class AppVersionAdmin(admin.ModelAdmin):
    list_display = ['platform', 'version', 'build_number', 'is_active', 'is_mandatory', 'created_at']
    list_filter = ['platform', 'is_active', 'is_mandatory']
    search_fields = ['version', 'release_notes']
    inlines = [AppFileInline]

@admin.register(AppFile)
class AppFileAdmin(admin.ModelAdmin):
    list_display = ['filename', 'app_version', 'file_size', 'download_count', 'created_at']
    list_filter = ['app_version__platform']
    search_fields = ['filename']
    readonly_fields = ['download_count']

@admin.register(DownloadStat)
class DownloadStatAdmin(admin.ModelAdmin):
    list_display = ['app_file', 'ip_address', 'downloaded_at']
    list_filter = ['downloaded_at']
    readonly_fields = ['app_file', 'ip_address', 'user_agent', 'downloaded_at']
