from django.core.management.base import BaseCommand
from downloads.models import AppVersion, AppFile
import os

class Command(BaseCommand):
    help = 'Add sample app versions for testing'

    def handle(self, *args, **kwargs):
        # Android
        android, created = AppVersion.objects.get_or_create(
            platform='android',
            version='1.0.0',
            defaults={
                'build_number': '100',
                'release_notes': 'Initial release with offline support and fingerprint login',
                'is_active': True,
            }
        )
        
        # iOS
        ios, created = AppVersion.objects.get_or_create(
            platform='ios',
            version='1.0.0',
            defaults={
                'build_number': '100',
                'release_notes': 'Initial release with offline support and Face ID',
                'is_active': True,
            }
        )
        
        # Windows
        windows, created = AppVersion.objects.get_or_create(
            platform='windows',
            version='1.0.0',
            defaults={
                'build_number': '100',
                'release_notes': 'Windows desktop app with full offline support',
                'is_active': True,
            }
        )
        
        self.stdout.write(self.style.SUCCESS('Sample app versions created'))
