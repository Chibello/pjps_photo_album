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
