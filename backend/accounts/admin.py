from django.contrib import admin

# Register your models here.
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User, LoginHistory

class CustomUserAdmin(UserAdmin):
    list_display = ('registration_number', 'email', 'first_name', 'last_name', 'user_type', 'is_active')
    list_filter = ('user_type', 'is_active', 'is_staff')
    search_fields = ('registration_number', 'first_name', 'last_name', 'email')
    ordering = ('registration_number',)
    fieldsets = (
        (None, {'fields': ('registration_number', 'password')}),
        ('Personal info', {'fields': ('first_name', 'last_name', 'email')}),
        ('Permissions', {'fields': ('user_type', 'is_active', 'is_staff', 'is_superuser', 'is_admin')}),
        ('Important dates', {'fields': ('last_login', 'date_joined')}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('registration_number', 'password1', 'password2', 'user_type', 'is_active'),
        }),
    )

admin.site.register(User, CustomUserAdmin)
admin.site.register(LoginHistory)
