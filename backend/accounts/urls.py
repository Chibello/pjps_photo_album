from django.urls import path
from . import views

urlpatterns = [
    path('login/', views.login_view, name='login'),
    path('logout/', views.logout_view, name='logout'),
    path('users/', views.UserListView.as_view(), name='user-list'),
    path('users/<uuid:id>/', views.UserDetailView.as_view(), name='user-detail'),
    path('users/<uuid:id>/change-password/', views.change_user_password, name='change-password'),
    path('users/<uuid:id>/reset-password/', views.reset_user_password, name='reset-password'),
    path('users/<uuid:id>/deactivate/', views.deactivate_user, name='deactivate-user'),
    path('users/<uuid:id>/activate/', views.activate_user, name='activate-user'),
]
