from django.urls import path
from . import views

urlpatterns = [
    path('', views.download_page, name='download_page'),
    path('file/<uuid:file_id>/', views.download_file, name='download_file'),
    path('api/versions/', views.get_app_versions, name='app_versions'),
]
