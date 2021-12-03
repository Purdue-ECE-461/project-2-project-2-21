from django.urls import path
from . import views
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('',views.index,name='index'),
    path('upload/',views.upload,name='upload'),
    path('download/',views.download,name='download'),
    path('packages/',views.package_list,name='package_list'),
    path('packages/upload/',views.upload_package,name='upload_package'),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL,document_root=settings.MEDIA_ROOT)