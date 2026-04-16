from rest_framework import serializers
from .models import (
    Department, StaffCategory, Staff,
    AdministrativeStaff, LibraryStaff
)

class DepartmentSerializer(serializers.ModelSerializer):
    staff_count = serializers.SerializerMethodField()
    
    class Meta:
        model = Department
        fields = ['id', 'name', 'code', 'description', 'staff_count', 'created_at']
    
    def get_staff_count(self, obj):
        return obj.staff_members.filter(is_active=True).count()

class StaffCategorySerializer(serializers.ModelSerializer):
    staff_count = serializers.SerializerMethodField()
    
    class Meta:
        model = StaffCategory
        fields = ['id', 'name', 'description', 'display_order', 'staff_count']
    
    def get_staff_count(self, obj):
        return obj.staff_members.filter(is_active=True).count()

class StaffListSerializer(serializers.ModelSerializer):
    full_name = serializers.CharField()
    category_name = serializers.CharField(source='category.name', read_only=True)
    department_name = serializers.CharField(source='department.name', read_only=True)
    profile_photo_thumbnail = serializers.SerializerMethodField()
    
    class Meta:
        model = Staff
        fields = [
            'id', 'staff_id', 'full_name', 'position',
            'category_name', 'department_name',
            'profile_photo_thumbnail', 'is_active'
        ]
    
    def get_profile_photo_thumbnail(self, obj):
        if obj.profile_photo_thumbnail:
            return obj.profile_photo_thumbnail.url
        return None

class StaffDetailSerializer(serializers.ModelSerializer):
    full_name = serializers.CharField()
    category_name = serializers.CharField(source='category.name', read_only=True)
    department_name = serializers.CharField(source='department.name', read_only=True)
    department_code = serializers.CharField(source='department.code', read_only=True)
    profile_photo_medium = serializers.SerializerMethodField()
    profile_photo_original = serializers.SerializerMethodField()
    
    admin_role = serializers.SerializerMethodField()
    manages_department = serializers.SerializerMethodField()
    
    library_section = serializers.SerializerMethodField()
    librarian_rank = serializers.SerializerMethodField()
    
    class Meta:
        model = Staff
        fields = [
            'id', 'staff_id', 'first_name', 'last_name',
            'other_names', 'full_name', 'date_of_birth',
            'category', 'category_name',
            'department', 'department_name', 'department_code',
            'position', 'employment_date',
            'work_email', 'work_phone', 'office_location',
            'office_hours', 'bio', 'qualifications', 'responsibilities',
            'profile_photo_medium', 'profile_photo_original',
            'admin_role', 'manages_department',
            'library_section', 'librarian_rank',
            'is_active', 'is_current_staff',
            'created_at', 'updated_at'
        ]
    
    def get_profile_photo_medium(self, obj):
        if obj.profile_photo_medium:
            return obj.profile_photo_medium.url
        return None
    
    def get_profile_photo_original(self, obj):
        if obj.profile_photo:
            return obj.profile_photo.url
        return None
    
    def get_admin_role(self, obj):
        if hasattr(obj, 'admin_details'):
            return obj.admin_details.admin_role
        return None
    
    def get_manages_department(self, obj):
        if hasattr(obj, 'admin_details') and obj.admin_details.manages_department:
            return {
                'id': str(obj.admin_details.manages_department.id),
                'name': obj.admin_details.manages_department.name
            }
        return None
    
    def get_library_section(self, obj):
        if hasattr(obj, 'library_details'):
            return {
                'code': obj.library_details.library_section,
                'name': obj.library_details.get_library_section_display()
            }
        return None
    
    def get_librarian_rank(self, obj):
        if hasattr(obj, 'library_details'):
            return obj.library_details.librarian_rank
        return None
