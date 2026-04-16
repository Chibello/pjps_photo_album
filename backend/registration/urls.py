from django.urls import path
from . import views
from .api import check_approval_status
#from . import api

app_name = 'registration'

urlpatterns = [
    path('', views.index, name='index'),
    path('student/', views.student_register, name='student_register'),
    path('staff/', views.staff_register, name='staff_register'),
    
    # Admin URLs
    path('admin/dashboard/', views.approval_dashboard, name='approval_dashboard'),
    path('admin/review/<uuid:submission_id>/', views.review_submission, name='review_submission'),
    path('admin/approve/<uuid:submission_id>/', views.approve_submission, name='approve_submission'),
    path('admin/reject/<uuid:submission_id>/', views.reject_submission, name='reject_submission'),
    path('api/check-status/', check_approval_status, name='check_status'),
]
