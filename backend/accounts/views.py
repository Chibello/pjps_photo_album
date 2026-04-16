from django.shortcuts import render

# Create your views here.
from rest_framework import status, generics, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import logout
from django.utils import timezone
from .models import User, LoginHistory
from .serializers import UserSerializer, UserDetailSerializer, LoginSerializer, ChangePasswordSerializer

@api_view(['POST'])
@permission_classes([permissions.AllowAny])
def login_view(request):
    serializer = LoginSerializer(data=request.data, context={'request': request})
    
    if serializer.is_valid():
        user = serializer.validated_data['user']
        
        refresh = RefreshToken.for_user(user)
        access_token = str(refresh.access_token)
        
        user.current_session_token = access_token
        user.save()
        
        ip_address = request.META.get('REMOTE_ADDR')
        user_agent = request.META.get('HTTP_USER_AGENT', '')
        
        LoginHistory.objects.create(
            user=user,
            ip_address=ip_address,
            device_info=user_agent,
            session_token=access_token
        )
        
        return Response({
            'success': True,
            'access_token': access_token,
            'refresh_token': str(refresh),
            'user': UserDetailSerializer(user).data
        })
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
def logout_view(request):
    try:
        user = request.user
        user.current_session_token = None
        user.save()
        
        try:
            refresh_token = request.data.get('refresh_token')
            if refresh_token:
                token = RefreshToken(refresh_token)
                token.blacklist()
        except:
            pass
        
        logout(request)
        
        return Response({'success': True, 'message': 'Logged out successfully'})
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
@permission_classes([permissions.IsAdminUser])
def change_user_password(request, user_id):
    try:
        user = User.objects.get(id=user_id)
    except User.DoesNotExist:
        return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)
    
    serializer = ChangePasswordSerializer(data=request.data)
    
    if serializer.is_valid():
        user.set_password(serializer.validated_data['new_password'])
        user.password_changed_at = timezone.now()
        user.current_session_token = None
        user.save()
        
        return Response({'success': True, 'message': 'Password changed successfully'})
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
@permission_classes([permissions.IsAdminUser])
def reset_user_password(request, user_id):
    try:
        user = User.objects.get(id=user_id)
    except User.DoesNotExist:
        return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)
    
    import secrets
    import string
    alphabet = string.ascii_letters + string.digits
    new_password = ''.join(secrets.choice(alphabet) for i in range(10))
    
    user.set_password(new_password)
    user.password_changed_at = timezone.now()
    user.current_session_token = None
    user.save()
    
    return Response({
        'success': True,
        'new_password': new_password,
        'message': 'Password reset successfully'
    })

@api_view(['POST'])
@permission_classes([permissions.IsAdminUser])
def deactivate_user(request, user_id):
    try:
        user = User.objects.get(id=user_id)
        user.is_active = False
        user.current_session_token = None
        user.save()
        return Response({'success': True, 'message': 'User deactivated'})
    except User.DoesNotExist:
        return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

@api_view(['POST'])
@permission_classes([permissions.IsAdminUser])
def activate_user(request, user_id):
    try:
        user = User.objects.get(id=user_id)
        user.is_active = True
        user.save()
        return Response({'success': True, 'message': 'User activated'})
    except User.DoesNotExist:
        return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

class UserListView(generics.ListAPIView):
    queryset = User.objects.all()
    serializer_class = UserDetailSerializer
    permission_classes = [permissions.IsAdminUser]
    filterset_fields = ['user_type', 'is_active']
    search_fields = ['registration_number', 'first_name', 'last_name', 'email']

class UserDetailView(generics.RetrieveUpdateAPIView):
    queryset = User.objects.all()
    serializer_class = UserDetailSerializer
    permission_classes = [permissions.IsAdminUser]
    lookup_field = 'id'
