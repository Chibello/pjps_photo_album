from rest_framework import serializers
from .models import RemarkBook, Remark, RemarkComment

class RemarkCommentSerializer(serializers.ModelSerializer):
    author_name = serializers.SerializerMethodField()
    
    class Meta:
        model = RemarkComment
        fields = ['id', 'author', 'author_name', 'content', 'created_at']
        read_only_fields = ['id', 'author', 'created_at']
    
    def get_author_name(self, obj):
        return obj.author.get_full_name() or obj.author.registration_number

class RemarkSerializer(serializers.ModelSerializer):
    author_name = serializers.SerializerMethodField()
    comments = RemarkCommentSerializer(many=True, read_only=True)
    comment_count = serializers.SerializerMethodField()
    
    class Meta:
        model = Remark
        fields = [
            'id', 'remark_book', 'author', 'author_name',
            'remark_type', 'visibility', 'title', 'content',
            'attachment', 'comments', 'comment_count',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'author', 'created_at', 'updated_at']
    
    def get_author_name(self, obj):
        if obj.author:
            return obj.author.get_full_name() or obj.author.registration_number
        return "Unknown"
    
    def get_comment_count(self, obj):
        return obj.comments.count()

class RemarkBookSerializer(serializers.ModelSerializer):
    remarks = RemarkSerializer(many=True, read_only=True)
    remark_count = serializers.SerializerMethodField()
    last_remark_date = serializers.SerializerMethodField()
    
    class Meta:
        model = RemarkBook
        fields = [
            'id', 'title', 'remarks', 'remark_count',
            'last_remark_date', 'created_at', 'updated_at'
        ]
    
    def get_remark_count(self, obj):
        return obj.remarks.count()
    
    def get_last_remark_date(self, obj):
        last_remark = obj.remarks.order_by('-created_at').first()
        if last_remark:
            return last_remark.created_at
        return None
