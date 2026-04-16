from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from albums.models import (
    AcademicYear, YearLevel, ClassGroup,
    Diocese, State, Student
)
from staff.models import Department, StaffCategory, Staff
import random
from faker import Faker

User = get_user_model()
fake = Faker()

class Command(BaseCommand):
    help = 'Seed database with initial data'
    
    def handle(self, *args, **kwargs):
        self.stdout.write('Seeding data...')
        
        # Create admin user
        if not User.objects.filter(registration_number='admin').exists():
            admin = User.objects.create_superuser(
                registration_number='admin',
                password='admin123',
                first_name='System',
                last_name='Administrator',
                user_type='ADMIN'
            )
            self.stdout.write(self.style.SUCCESS('Admin user created'))
        
        # Create academic years
        years = [
            {'name': '2023/2024', 'start_date': '2023-09-01', 'end_date': '2024-08-31', 'is_current': True},
            {'name': '2024/2025', 'start_date': '2024-09-01', 'end_date': '2025-08-31'},
        ]
        
        for year_data in years:
            AcademicYear.objects.get_or_create(
                name=year_data['name'],
                defaults=year_data
            )
        
        # Create year levels
        year_levels = ['Year 1', 'Year 2', 'Year 3', 'Year 4']
        for i, year_name in enumerate(year_levels):
            YearLevel.objects.get_or_create(
                name=year_name,
                defaults={'display_order': i + 1}
            )
        
        # Create dioceses
        dioceses = ['Abuja', 'Lagos', 'Onitsha', 'Enugu', 'Calabar']
        for diocese_name in dioceses:
            Diocese.objects.get_or_create(name=diocese_name)
        
        # Create states
        states = ['Lagos', 'Abuja', 'Enugu', 'Anambra', 'Imo']
        for state_name in states:
            State.objects.get_or_create(name=state_name)
        
        # Create departments
        departments = [
            {'name': 'Computer Science', 'code': 'CSC'},
            {'name': 'Mathematics', 'code': 'MTH'},
        ]
        
        for dept in departments:
            Department.objects.get_or_create(
                code=dept['code'],
                defaults={'name': dept['name']}
            )
        
        # Create staff categories
        categories = [
            {'name': 'Administrative', 'display_order': 1},
            {'name': 'Academic', 'display_order': 2},
        ]
        
        for cat in categories:
            StaffCategory.objects.get_or_create(
                name=cat['name'],
                defaults={'display_order': cat['display_order']}
            )
        
        self.stdout.write(self.style.SUCCESS('Data seeding completed'))
