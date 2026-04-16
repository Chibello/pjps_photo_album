from django.shortcuts import render

# Create your views here.
from rest_framework import generics, permissions, status, filters
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from django.shortcuts import get_object_or_404
from .models import (
    AcademicYear, YearLevel, ClassGroup,
    Diocese, State, Student, Photo
)
from .serializers2 import (
    AcademicYearSerializer, YearLevelSerializer, ClassGroupSerializer,
    DioceseSerializer, StateSerializer, StudentListSerializer,
    StudentDetailSerializer, PhotoSerializer
)
from accounts.permissions import IsAdminUser

class AcademicYearListView(generics.ListCreateAPIView):
    queryset = AcademicYear.objects.all()
    serializer_class = AcademicYearSerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['name']
    ordering_fields = ['start_date', 'end_date']

class AcademicYearDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = AcademicYear.objects.all()
    serializer_class = AcademicYearSerializer
    permission_classes = [permissions.IsAuthenticated, IsAdminUser]
    lookup_field = 'id'

class YearLevelListView(generics.ListCreateAPIView):
    queryset = YearLevel.objects.all()
    serializer_class = YearLevelSerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [filters.OrderingFilter]
    ordering_fields = ['display_order']

class YearLevelDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = YearLevel.objects.all()
    serializer_class = YearLevelSerializer
    permission_classes = [permissions.IsAuthenticated, IsAdminUser]
    lookup_field = 'id'

class ClassGroupListView(generics.ListCreateAPIView):
    queryset = ClassGroup.objects.filter(is_active=True)
    serializer_class = ClassGroupSerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['year_level', 'academic_year', 'is_active']
    search_fields = ['name']
    ordering_fields = ['year_level__display_order', 'name']

class ClassGroupDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = ClassGroup.objects.all()
    serializer_class = ClassGroupSerializer
    permission_classes = [permissions.IsAuthenticated]
    lookup_field = 'id'

class ClassGroupStudentsView(generics.ListAPIView):
    serializer_class = StudentListSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        class_id = self.kwargs['id']
        return Student.objects.filter(
            current_class_id=class_id,
            is_active=True
        ).select_related('diocese', 'state_of_origin')

class StudentListView(generics.ListCreateAPIView):
    queryset = Student.objects.filter(is_active=True)
    serializer_class = StudentListSerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['current_class', 'diocese', 'state_of_origin', 'is_graduated']
    search_fields = ['first_name', 'last_name', 'registration_number', 'hometown']
    ordering_fields = ['last_name', 'first_name', 'registration_number']

class StudentDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Student.objects.all()
    serializer_class = StudentDetailSerializer
    permission_classes = [permissions.IsAuthenticated]
    lookup_field = 'id'

class DioceseListView(generics.ListCreateAPIView):
    queryset = Diocese.objects.all()
    serializer_class = DioceseSerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [filters.SearchFilter]
    search_fields = ['name']

class StateListView(generics.ListCreateAPIView):
    queryset = State.objects.all()
    serializer_class = StateSerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [filters.SearchFilter]
    search_fields = ['name']

@api_view(['POST'])
@permission_classes([IsAdminUser])
def upload_student_photo(request, student_id):
    student = get_object_or_404(Student, id=student_id)
    
    if 'photo' not in request.FILES:
        return Response({'error': 'No photo provided'}, status=status.HTTP_400_BAD_REQUEST)
    
    if request.data.get('is_profile') == 'true':
        student.profile_photo = request.FILES['photo']
        student.save()
        serializer = StudentDetailSerializer(student)
        return Response(serializer.data)
    
    photo = Photo.objects.create(
        title=request.data.get('title', ''),
        image=request.FILES['photo'],
        uploaded_by=request.user
    )
    
    student.additional_photos.add(photo)
    
    return Response(PhotoSerializer(photo).data, status=status.HTTP_201_CREATED)

@api_view(['POST'])
@permission_classes([IsAdminUser])
def upload_batch_photos(request):
    if 'photos' not in request.FILES:
        return Response({'error': 'No photos provided'}, status=status.HTTP_400_BAD_REQUEST)
    
    photos = request.FILES.getlist('photos')
    uploaded_photos = []
    
    for photo_file in photos:
        photo = Photo.objects.create(
            image=photo_file,
            uploaded_by=request.user
        )
        uploaded_photos.append(photo)
    
    serializer = PhotoSerializer(uploaded_photos, many=True)
    return Response(serializer.data, status=status.HTTP_201_CREATED)

@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def get_dashboard_stats(request):
    stats = {
        'total_students': Student.objects.filter(is_active=True).count(),
        'total_classes': ClassGroup.objects.filter(is_active=True).count(),
        'total_year_levels': YearLevel.objects.filter(is_active=True).count(),
        'students_by_year': []
    }
    
    for year in YearLevel.objects.filter(is_active=True).order_by('display_order'):
        count = Student.objects.filter(
            current_class__year_level=year,
            is_active=True
        ).count()
        stats['students_by_year'].append({
            'year': year.name,
            'count': count
        })
    
    return Response(stats)
