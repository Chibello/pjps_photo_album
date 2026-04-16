from django.urls import path
from . import views

urlpatterns = [
    path('departments/', views.DepartmentListView.as_view(), name='department-list'),
    path('departments/<uuid:id>/', views.DepartmentDetailView.as_view(), name='department-detail'),
    
    path('categories/', views.StaffCategoryListView.as_view(), name='staff-category-list'),
    path('categories/<uuid:id>/', views.StaffCategoryDetailView.as_view(), name='staff-category-detail'),
    
    path('staff/', views.StaffListView.as_view(), name='staff-list'),
    path('staff/<uuid:id>/', views.StaffDetailView.as_view(), name='staff-detail'),
]
