from django.shortcuts import render

# Create your views here.
from rest_framework import generics, permissions, filters
from django_filters.rest_framework import DjangoFilterBackend
from .models import Department, StaffCategory, Staff
from .serializers import (
    DepartmentSerializer, StaffCategorySerializer,
    StaffListSerializer, StaffDetailSerializer
)

class DepartmentListView(generics.ListCreateAPIView):
    queryset = Department.objects.all()
    serializer_class = DepartmentSerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [filters.SearchFilter]
    search_fields = ['name', 'code']

class DepartmentDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Department.objects.all()
    serializer_class = DepartmentSerializer
    permission_classes = [permissions.IsAuthenticated]
    lookup_field = 'id'

class StaffCategoryListView(generics.ListCreateAPIView):
    queryset = StaffCategory.objects.all()
    serializer_class = StaffCategorySerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [filters.OrderingFilter]
    ordering_fields = ['display_order']

class StaffCategoryDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = StaffCategory.objects.all()
    serializer_class = StaffCategorySerializer
    permission_classes = [permissions.IsAuthenticated]
    lookup_field = 'id'

class StaffListView(generics.ListCreateAPIView):
    queryset = Staff.objects.filter(is_active=True)
    serializer_class = StaffListSerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['category', 'department', 'is_current_staff']
    search_fields = ['first_name', 'last_name', 'staff_id', 'position']
    ordering_fields = ['last_name', 'first_name', 'employment_date']

class StaffDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Staff.objects.all()
    serializer_class = StaffDetailSerializer
    permission_classes = [permissions.IsAuthenticated]
    lookup_field = 'id'
