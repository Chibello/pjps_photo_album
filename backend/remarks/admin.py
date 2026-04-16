from django.contrib import admin

# Register your models here.
from django.contrib import admin
from .models import RemarkBook, Remark, RemarkComment

class RemarkInline(admin.TabularInline):
    model = Remark
    extra = 0

@admin.register(RemarkBook)
class RemarkBookAdmin(admin.ModelAdmin):
    list_display = ['id', 'title', 'content_type', 'object_id', 'created_at']
    inlines = [RemarkInline]

@admin.register(Remark)
class RemarkAdmin(admin.ModelAdmin):
    list_display = ['title', 'author', 'remark_type', 'visibility', 'created_at']
    list_filter = ['remark_type', 'visibility']
    search_fields = ['title', 'content']

@admin.register(RemarkComment)
class RemarkCommentAdmin(admin.ModelAdmin):
    list_display = ['id', 'author', 'remark', 'created_at']
