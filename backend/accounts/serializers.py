from rest_framework import serializers
from django.contrib.auth import authenticate
from .models import User, LoginHistory

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'registration_number', 'first_name', 'last_name', 
                 'email', 'user_type', 'is_active', 'date_joined']
        read_only_fields = ['id', 'date_joined']

class UserDetailSerializer(serializers.ModelSerializer):
    full_name = serializers.SerializerMethodField()
    
    class Meta:
        model = User
        fields = ['id', 'registration_number', 'first_name', 'last_name', 
                 'full_name', 'email', 'user_type', 'is_active', 'date_joined']
    
    def get_full_name(self, obj):
        return obj.get_full_name()

class LoginSerializer(serializers.Serializer):
    registration_number = serializers.CharField()
    password = serializers.CharField(write_only=True)
    
    def validate(self, data):
        registration_number = data.get('registration_number')
        password = data.get('password')
        
        if registration_number and password:
            user = authenticate(
                request=self.context.get('request'),
                username=registration_number,
                password=password
            )
            
            if not user:
                raise serializers.ValidationError('Invalid credentials')
            
            if not user.is_active:
                raise serializers.ValidationError('Account is deactivated')
            
            data['user'] = user
        else:
            raise serializers.ValidationError('Must include registration_number and password')
        
        return data

class ChangePasswordSerializer(serializers.Serializer):
    new_password = serializers.CharField(write_only=True, min_length=8)
    confirm_password = serializers.CharField(write_only=True, min_length=8)
    
    def validate(self, data):
        if data['new_password'] != data['confirm_password']:
            raise serializers.ValidationError("Passwords don't match")
        return data
