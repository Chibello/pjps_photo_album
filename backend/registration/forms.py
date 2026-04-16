from django import forms
from albums.models import Diocese, State
from .models import StudentPending, StaffPending
from django import forms
#from .models import Member
from .choices import STATE_CHOICES, DIOCESE_CHOICES

class DateInput(forms.DateInput):
    input_type = 'date'
    attrs = {'class': 'form-control'}

class StudentRegistrationForm(forms.ModelForm):
    """Form for student registration"""
    
    confirm_password = forms.CharField(
        widget=forms.PasswordInput(attrs={'class': 'form-control', 'placeholder': 'Confirm Password'}),
        label="Confirm Password"
    )
    
    class Meta:
        model = StudentPending
        fields = [
            'full_name', 'registration_number', 'email', 'phone',
            'diocese', 'hometown', 'state',
            'date_of_birth', 'year_level', 'previous_school',
            'guardian_name', 'guardian_phone', 'guardian_email',
            'photo', 'preferred_password'
        ]
        widgets = {
            'full_name': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'Enter your full name',
                'required': True
            }),
            'registration_number': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'Enter registration number',
                'required': True
            }),
            'email': forms.EmailInput(attrs={
                'class': 'form-control',
                'placeholder': 'Enter email address (optional)'
            }),
            'phone': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'Enter phone number (optional)'
            }),
            'diocese': forms.Select(attrs={
                'class': 'form-control',
            }),
            'hometown': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'Enter your hometown',
                'required': True
            }),
            'state': forms.Select(attrs={
                'class': 'form-control',
            }),
            'date_of_birth': DateInput(attrs={
                'class': 'form-control',
            }),
            'year_level': forms.Select(choices=[
                ('', 'Select Year Level'),
                ('Year 1', 'Year 1'),
                ('Year 2', 'Year 2'),
                ('Year 3', 'Year 3'),
                ('Year 4', 'Year 4'),
            ], attrs={'class': 'form-control'}),
            'previous_school': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'Previous school attended (optional)'
            }),
            'guardian_name': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'Guardian/Parent name (optional)'
            }),
            'guardian_phone': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'Guardian phone (optional)'
            }),
            'guardian_email': forms.EmailInput(attrs={
                'class': 'form-control',
                'placeholder': 'Guardian email (optional)'
            }),
            'photo': forms.FileInput(attrs={
                'class': 'form-control',
                'accept': 'image/*'
            }),
            'preferred_password': forms.PasswordInput(attrs={
                'class': 'form-control',
                'placeholder': 'Choose a password',
                'required': True
            }),
        }
        labels = {
            'full_name': 'Full Name *',
            'registration_number': 'Registration Number *',
            'email': 'Email Address',
            'phone': 'Phone Number',
            'diocese': 'Diocese *',
            'hometown': 'Hometown *',
            'state': 'State of Origin *',
            'date_of_birth': 'Date of Birth',
            'year_level': 'Year Level',
            'previous_school': 'Previous School',
            'guardian_name': 'Guardian/Parent Name',
            'guardian_phone': 'Guardian Phone',
            'guardian_email': 'Guardian Email',
            'photo': 'Profile Photo',
            'preferred_password': 'Preferred Password *',
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Populate diocese and state choices
        self.fields['diocese'].queryset = Diocese.objects.all().order_by('name')
        self.fields['diocese'].empty_label = "Select Diocese"
        self.fields['state'].queryset = State.objects.all().order_by('name')
        self.fields['state'].empty_label = "Select State"
        
        # Make some fields optional
        self.fields['email'].required = False
        self.fields['phone'].required = False
        self.fields['date_of_birth'].required = False
        self.fields['year_level'].required = False
        self.fields['photo'].required = False

    def clean_registration_number(self):
        reg_no = self.cleaned_data['registration_number']
        # Check if already exists in User or Pending
        from django.contrib.auth import get_user_model
        User = get_user_model()
        
        if User.objects.filter(registration_number=reg_no).exists():
            raise forms.ValidationError("This registration number already exists in the system.")
        
        if StudentPending.objects.filter(registration_number=reg_no, status='PENDING').exists():
            raise forms.ValidationError("A pending registration with this number already exists.")
        
        return reg_no

    def clean(self):
        cleaned_data = super().clean()
        password = cleaned_data.get('preferred_password')
        confirm = cleaned_data.get('confirm_password')
        
        if password and confirm and password != confirm:
            raise forms.ValidationError("Passwords do not match.")
        
        return cleaned_data

class StaffRegistrationForm(forms.ModelForm):
    """Form for staff registration"""
    
    confirm_password = forms.CharField(
        widget=forms.PasswordInput(attrs={'class': 'form-control', 'placeholder': 'Confirm Password'}),
        label="Confirm Password"
    )
    
    class Meta:
        model = StaffPending
        fields = [
            'full_name', 'registration_number', 'email', 'phone',
            'diocese', 'hometown', 'state',
            'staff_category', 'position', 'department',
            'qualifications', 'years_of_experience',
            'emergency_contact', 'emergency_phone',
            'photo', 'preferred_password'
        ]
        widgets = {
            'full_name': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'Enter your full name',
                'required': True
            }),
            'registration_number': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'Enter staff ID',
                'required': True
            }),
            'email': forms.EmailInput(attrs={
                'class': 'form-control',
                'placeholder': 'Enter work email',
                'required': True
            }),
            'phone': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'Enter work phone',
                'required': True
            }),
            'diocese': forms.Select(attrs={
                'class': 'form-control',
            }),
            'hometown': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'Enter your hometown',
                'required': True
            }),
            'state': forms.Select(attrs={
                'class': 'form-control',
            }),
            'staff_category': forms.Select(attrs={
                'class': 'form-control',
            }),
            'position': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'Enter your position/title',
                'required': True
            }),
            'department': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'Enter department (optional)'
            }),
            'qualifications': forms.Textarea(attrs={
                'class': 'form-control',
                'placeholder': 'List your qualifications',
                'rows': 3
            }),
            'years_of_experience': forms.NumberInput(attrs={
                'class': 'form-control',
                'placeholder': 'Years of experience'
            }),
            'emergency_contact': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'Emergency contact name'
            }),
            'emergency_phone': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'Emergency contact phone'
            }),
            'photo': forms.FileInput(attrs={
                'class': 'form-control',
                'accept': 'image/*'
            }),
            'preferred_password': forms.PasswordInput(attrs={
                'class': 'form-control',
                'placeholder': 'Choose a password',
                'required': True
            }),
        }
        labels = {
            'full_name': 'Full Name *',
            'registration_number': 'Staff ID *',
            'email': 'Work Email *',
            'phone': 'Work Phone *',
            'diocese': 'Diocese *',
            'hometown': 'Hometown *',
            'state': 'State of Origin *',
            'staff_category': 'Staff Category *',
            'position': 'Position/Title *',
            'department': 'Department',
            'qualifications': 'Qualifications',
            'years_of_experience': 'Years of Experience',
            'emergency_contact': 'Emergency Contact',
            'emergency_phone': 'Emergency Phone',
            'photo': 'Profile Photo',
            'preferred_password': 'Preferred Password *',
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['diocese'].queryset = Diocese.objects.all().order_by('name')
        self.fields['diocese'].empty_label = "Select Diocese"
        self.fields['state'].queryset = State.objects.all().order_by('name')
        self.fields['state'].empty_label = "Select State"
        
        self.fields['email'].required = True
        self.fields['phone'].required = True
        self.fields['photo'].required = False

    def clean_registration_number(self):
        staff_id = self.cleaned_data['registration_number']
        from django.contrib.auth import get_user_model
        User = get_user_model()
        
        if User.objects.filter(registration_number=staff_id).exists():
            raise forms.ValidationError("This Staff ID already exists in the system.")
        
        if StaffPending.objects.filter(registration_number=staff_id, status='PENDING').exists():
            raise forms.ValidationError("A pending registration with this ID already exists.")
        
        return staff_id

    def clean(self):
        cleaned_data = super().clean()
        password = cleaned_data.get('preferred_password')
        confirm = cleaned_data.get('confirm_password')
        
        if password and confirm and password != confirm:
            raise forms.ValidationError("Passwords do not match.")
        
        return cleaned_data
