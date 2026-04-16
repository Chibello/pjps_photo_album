from django.contrib import admin
from .models import AcademicYear, YearLevel, Diocese, State, Student, Photo


# ============================
# ACADEMIC YEAR
# ============================

@admin.register(AcademicYear)
class AcademicYearAdmin(admin.ModelAdmin):
    list_display = ['name', 'start_date', 'end_date', 'is_current']
    list_filter = ['is_current']
    search_fields = ['name']


# ============================
# YEAR LEVEL
# ============================

@admin.register(YearLevel)
class YearLevelAdmin(admin.ModelAdmin):
    list_display = ['name', 'display_order', 'is_active']
    list_editable = ['display_order']
    list_filter = ['is_active']
    search_fields = ['name']


# ============================
# LOCATION MODELS
# ============================

@admin.register(Diocese)
class DioceseAdmin(admin.ModelAdmin):
    list_display = ['name']
    search_fields = ['name']


@admin.register(State)
class StateAdmin(admin.ModelAdmin):
    list_display = ['name']
    search_fields = ['name']


# ============================
# STUDENT
# ============================

@admin.register(Student)
class StudentAdmin(admin.ModelAdmin):
    list_display = ['registration_number', 'last_name', 'first_name', 'year_level', 'is_active', 'is_graduated']
    list_filter = ['year_level', 'is_active', 'is_graduated']
    search_fields = ['registration_number', 'first_name', 'last_name']


# ============================
# PHOTO
# ============================

@admin.register(Photo)
class PhotoAdmin(admin.ModelAdmin):
    list_display = ['id', 'title', 'uploaded_by', 'uploaded_at']
    list_filter = ['uploaded_at']
    search_fields = ['title']