from django.core.management.base import BaseCommand
from albums.models import State, Diocese

class Command(BaseCommand):
    help = "Load all Nigerian states and selected dioceses into the database"

    def handle(self, *args, **kwargs):
        states = [
            "Abia", "Adamawa", "Akwa Ibom", "Anambra", "Bauchi", "Bayelsa", "Benue",
            "Borno", "Cross River", "Delta", "Ebonyi", "Edo", "Ekiti", "Enugu", 
            "FCT Abuja", "Gombe", "Imo", "Jigawa", "Kaduna", "Kano", "Katsina", 
            "Kebbi", "Kogi", "Kwara", "Lagos", "Nasarawa", "Niger", "Ogun", "Ondo", 
            "Osun", "Oyo", "Plateau", "Rivers", "Sokoto", "Taraba", "Yobe", "Zamfara"
        ]

        dioceses = [
            "Awgu", "Nnewi", "Aguleri", "Ekwulobia", "Awka", "Enugu", 
            "Owerri", "Abuja", "Lagos", "Ibadan", "Benin City", "Calabar", "Nsukka", 
            "Jos", "Kaduna", "Onitsha", "Abakaliki", "Ahiara", "Aba", "Ado Ekiti", "Abeokuta", "Abakaliki",
            "Ahiara", "Aba", "Ado Ekiti", "Abeokuta", "Abakaliki", "Ahiara", "Aba", "Ado Ekiti", "Abeokuta", "Abakaliki",
            
        ]

        for s in states:
            State.objects.get_or_create(name=s)

        for d in dioceses:
            Diocese.objects.get_or_create(name=d)

        self.stdout.write(self.style.SUCCESS('✅ All states and dioceses have been added!'))