from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .models import StudentPending, StaffPending

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def check_approval_status(request):
    """API for app to check if user's registration is approved"""
    reg_number = request.query_params.get('registration_number')
    
    if not reg_number:
        return Response({'error': 'Registration number required'}, status=400)
    
    # Check if user exists (approved)
    from django.contrib.auth import get_user_model
    User = get_user_model()
    
    if User.objects.filter(registration_number=reg_number).exists():
        return Response({
            'status': 'approved',
            'message': 'Your account is active. You can login!'
        })
    
    # Check pending status
    student_pending = StudentPending.objects.filter(
        registration_number=reg_number
    ).first()
    
    staff_pending = StaffPending.objects.filter(
        registration_number=reg_number
    ).first()
    
    pending = student_pending or staff_pending
    
    if pending:
        return Response({
            'status': pending.status.lower(),
            'submitted_at': pending.submitted_at,
            'estimated_time': '24-48 hours' if pending.status == 'PENDING' else None,
            'message': get_status_message(pending.status)
        })
    
    return Response({
        'status': 'not_found',
        'message': 'No registration found with this number'
    })

def get_status_message(status):
    messages = {
        'PENDING': 'Your registration is under review. You will receive an email once approved.',
        'APPROVED': 'Your registration is approved! You can login now.',
        'REJECTED': 'Your registration was not approved. Please contact admin.',
        'NEEDS_EDIT': 'Please resubmit your registration with corrections.',
    }
    return messages.get(status, 'Status unknown')
