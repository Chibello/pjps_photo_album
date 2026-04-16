from django.contrib import admin

# Register your models here.
from django.contrib import admin
from .models import Department, StaffCategory, Staff, AdministrativeStaff, LibraryStaff

@admin.register(Department)
class DepartmentAdmin(admin.ModelAdmin):
    list_display = ['name', 'code']
    search_fields = ['name', 'code']

@admin.register(StaffCategory)
class StaffCategoryAdmin(admin.ModelAdmin):
    list_display = ['name', 'display_order']
    list_editable = ['display_order']

@admin.register(Staff)
class StaffAdmin(admin.ModelAdmin):
    list_display = ['staff_id', 'last_name', 'first_name', 'category', 'department', 'position']
    list_filter = ['category', 'department', 'is_current_staff']
    search_fields = ['staff_id', 'first_name', 'last_name']

@admin.register(AdministrativeStaff)
class AdministrativeStaffAdmin(admin.ModelAdmin):
    list_display = ['staff', 'admin_role']

@admin.register(LibraryStaff)
class LibraryStaffAdmin(admin.ModelAdmin):
    list_display = ['staff', 'library_section', 'librarian_rank']
