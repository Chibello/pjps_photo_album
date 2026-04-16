from django.urls import path
from . import views

urlpatterns = [
    path('dashboard/stats/', views.get_dashboard_stats, name='dashboard-stats'),
    
    path('academic-years/', views.AcademicYearListView.as_view(), name='academic-year-list'),
    path('academic-years/<uuid:id>/', views.AcademicYearDetailView.as_view(), name='academic-year-detail'),
    
    path('year-levels/', views.YearLevelListView.as_view(), name='year-level-list'),
    path('year-levels/<uuid:id>/', views.YearLevelDetailView.as_view(), name='year-level-detail'),
    
    #path('classes/', views2.ClassGroupListView.as_view(), name='class-list'),
    #path('classes/<uuid:id>/', views2.ClassGroupDetailView.as_view(), name='class-detail'),
    #path('classes/<uuid:id>/students/', views2.ClassGroupStudentsView.as_view(), name='class-students'),
    
    path('students/', views.StudentListView.as_view(), name='student-list'),
    path('students/<uuid:id>/', views.StudentDetailView.as_view(), name='student-detail'),
    path('students/<uuid:id>/upload-photo/', views.upload_student_photo, name='upload-student-photo'),
    
    path('photos/batch-upload/', views.upload_batch_photos, name='batch-upload-photos'),
    
    path('dioceses/', views.DioceseListView.as_view(), name='diocese-list'),
    path('states/', views.StateListView.as_view(), name='state-list'),
    path('students/by-year/<uuid:year_level_id>/', views.get_students_by_year, name='students-by-year'),
]
