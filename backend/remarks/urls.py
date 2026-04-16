from django.urls import path
from . import views

urlpatterns = [
    path('books/<str:content_type>/<uuid:object_id>/', 
         views.remark_book_view, name='remark-book'),
    path('remarks/<uuid:remark_id>/', 
         views.remark_detail_view, name='remark-detail'),
    path('remarks/<uuid:remark_id>/comments/', 
         views.add_comment, name='add-comment'),
    path('search/', 
         views.search_remarks, name='search-remarks'),
]
