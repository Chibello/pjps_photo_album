from rest_framework import serializers
from .models2 import (
    AcademicYear, YearLevel, ClassGroup, 
    Diocese, State, Student, Photo
)
from accounts.serializers import UserSerializer

class AcademicYearSerializer(serializers.ModelSerializer):
    class Meta:
        model = AcademicYear
        fields = '__all__'

class YearLevelSerializer(serializers.ModelSerializer):
    class_count = serializers.SerializerMethodField()
    student_count = serializers.SerializerMethodField()
    
    class Meta:
        model = YearLevel
        fields = ['id', 'name', 'display_order', 'is_active', 'class_count', 'student_count']
    
    def get_class_count(self, obj):
        return obj.classes.filter(is_active=True).count()
    
    def get_student_count(self, obj):
        return Student.objects.filter(current_class__year_level=obj, is_active=True).count()

class DioceseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Diocese
        fields = '__all__'

class StateSerializer(serializers.ModelSerializer):
    class Meta:
        model = State
        fields = '__all__'

class PhotoSerializer(serializers.ModelSerializer):
    thumbnail_url = serializers.SerializerMethodField()
    medium_url = serializers.SerializerMethodField()
    full_url = serializers.SerializerMethodField()
    
    class Meta:
        model = Photo
        fields = ['id', 'title', 'thumbnail_url', 'medium_url', 'full_url', 'uploaded_at']
    
    def get_thumbnail_url(self, obj):
        if obj.thumbnail:
            return obj.thumbnail.url
        return None
    
    def get_medium_url(self, obj):
        if obj.medium:
            return obj.medium.url
        return None
    
    def get_full_url(self, obj):
        if obj.image:
            return obj.image.url
        return None

class StudentListSerializer(serializers.ModelSerializer):
    full_name = serializers.CharField()
    profile_photo_thumbnail = serializers.SerializerMethodField()
    class_name = serializers.SerializerMethodField()
    
    class Meta:
        model = Student
        fields = [
            'id', 'registration_number', 'full_name', 
            'profile_photo_thumbnail', 'class_name', 
            'is_active', 'is_graduated'
        ]
    
    def get_profile_photo_thumbnail(self, obj):
        if obj.profile_photo_thumbnail:
            return obj.profile_photo_thumbnail.url
        return None
    
    def get_class_name(self, obj):
        if obj.current_class:
            return f"{obj.current_class.year_level.name} - {obj.current_class.name}"
        return "Not Assigned"

class StudentDetailSerializer(serializers.ModelSerializer):
    full_name = serializers.CharField()
    profile_photo_small = serializers.SerializerMethodField()
    profile_photo_medium = serializers.SerializerMethodField()
    profile_photo_original = serializers.SerializerMethodField()
    diocese_name = serializers.CharField(source='diocese.name', read_only=True)
    state_name = serializers.CharField(source='state_of_origin.name', read_only=True)
    class_detail = serializers.SerializerMethodField()
    additional_photos = PhotoSerializer(many=True, read_only=True)
    
    class Meta:
        model = Student
        fields = [
            'id', 'registration_number', 'first_name', 'last_name',
            'other_names', 'full_name', 'date_of_birth',
            'diocese', 'diocese_name', 'hometown', 'state_of_origin', 'state_name',
            'current_class', 'class_detail', 'enrollment_date',
            'profile_photo_small', 'profile_photo_medium', 'profile_photo_original',
            'additional_photos', 'is_graduated', 'is_active', 'personal_notes',
            'created_at', 'updated_at'
        ]
    
    def get_profile_photo_small(self, obj):
        if obj.profile_photo_small:
            return obj.profile_photo_small.url
        return None
    
    def get_profile_photo_medium(self, obj):
        if obj.profile_photo_medium:
            return obj.profile_photo_medium.url
        return None
    
    def get_profile_photo_original(self, obj):
        if obj.profile_photo:
            return obj.profile_photo.url
        return None
    
    def get_class_detail(self, obj):
        if obj.current_class:
            return {
                'id': str(obj.current_class.id),
                'name': obj.current_class.name,
                'year_level': obj.current_class.year_level.name,
                'academic_year': obj.current_class.academic_year.name
            }
        return None

class ClassGroupSerializer(serializers.ModelSerializer):
    year_level_name = serializers.CharField(source='year_level.name', read_only=True)
    academic_year_name = serializers.CharField(source='academic_year.name', read_only=True)
    student_count = serializers.SerializerMethodField()
    
    class Meta:
        model = ClassGroup
        fields = [
            'id', 'name', 'year_level', 'year_level_name',
            'academic_year', 'academic_year_name',
            'class_teacher', 'is_active', 'notes',
            'student_count', 'created_at', 'updated_at'
        ]
    
    def get_student_count(self, obj):
        return obj.students.filter(is_active=True).count()


#=============
'''
class StudentListSerializer(serializers.ModelSerializer):
    full_name = serializers.CharField(read_only=True)
    profile_photo_thumbnail = serializers.SerializerMethodField()
    year_level_name = serializers.CharField(source='year_level.name', read_only=True)

    class Meta:
        model = Student
        fields = [
            'id',
            'registration_number',
            'full_name',
            'profile_photo_thumbnail',
            'year_level',
            'year_level_name',
            'is_active',
            'is_graduated'
        ]
'''
#==============