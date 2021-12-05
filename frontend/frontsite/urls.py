from django.urls import path
from . import views
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('',views.index,name='index'),
    path('download/',views.download,name='download'),
    path('packages/',views.PackageListView.as_view(),name='package_list'),
    path('packages/upload/',views.UploadPackageView.as_view(),name='upload_package'),
    path('packages/<pk>',views.DeletePackageView.as_view(),name='delete_package')
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL,document_root=settings.MEDIA_ROOT)