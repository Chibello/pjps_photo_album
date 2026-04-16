from django.shortcuts import render

# Create your views here.
from rest_framework import generics, permissions, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from django.contrib.contenttypes.models import ContentType
from django.shortcuts import get_object_or_404
from .models import RemarkBook, Remark, RemarkComment
from .serializers import RemarkBookSerializer, RemarkSerializer, RemarkCommentSerializer

@api_view(['GET', 'POST'])
@permission_classes([permissions.IsAuthenticated])
def remark_book_view(request, content_type, object_id):
    try:
        ct = ContentType.objects.get(model=content_type)
    except ContentType.DoesNotExist:
        return Response({'error': 'Invalid content type'}, status=status.HTTP_400_BAD_REQUEST)
    
    remark_book, created = RemarkBook.objects.get_or_create(
        content_type=ct,
        object_id=object_id
    )
    
    if request.method == 'GET':
        serializer = RemarkBookSerializer(remark_book)
        return Response(serializer.data)
    
    elif request.method == 'POST':
        data = request.data.copy()
        data['remark_book'] = remark_book.id
        
        serializer = RemarkSerializer(data=data)
        if serializer.is_valid():
            serializer.save(author=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET', 'PUT', 'DELETE'])
@permission_classes([permissions.IsAuthenticated])
def remark_detail_view(request, remark_id):
    remark = get_object_or_404(Remark, id=remark_id)
    
    if request.method in ['PUT', 'DELETE']:
        if not (request.user == remark.author or request.user.is_admin):
            return Response(
                {'error': 'Permission denied'},
                status=status.HTTP_403_FORBIDDEN
            )
    
    if request.method == 'GET':
        serializer = RemarkSerializer(remark)
        return Response(serializer.data)
    
    elif request.method == 'PUT':
        serializer = RemarkSerializer(remark, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    elif request.method == 'DELETE':
        remark.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def add_comment(request, remark_id):
    remark = get_object_or_404(Remark, id=remark_id)
    
    serializer = RemarkCommentSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save(
            remark=remark,
            author=request.user
        )
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def search_remarks(request):
    query = request.query_params.get('q', '')
    remark_type = request.query_params.get('type')
    
    remarks = Remark.objects.filter(
        content__icontains=query
    ) | Remark.objects.filter(
        title__icontains=query
    )
    
    if remark_type:
        remarks = remarks.filter(remark_type=remark_type)
    
    remarks = remarks.order_by('-created_at')[:50]
    
    serializer = RemarkSerializer(remarks, many=True)
    return Response(serializer.data)
