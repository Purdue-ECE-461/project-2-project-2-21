from django.urls import path, include
from . import views
from django.conf import settings
from django.conf.urls.static import static
from rest_framework.authtoken.views import obtain_auth_token
from rest_framework.urlpatterns import format_suffix_patterns

urlpatterns = [
    path('',views.index,name='index'),
    path('login/',views.login.as_view(),name='login'),
    path('register/',views.register,name='register'),
    path('logintoken/',obtain_auth_token,name='logintoken'),
    path('packages/',views.PackageListView.as_view(),name='package_list'),
    path('packages/upload/',views.UploadPackageView.as_view(),name='upload_package'),
    path('packages/<pk>',views.DeletePackageView.as_view(),name='delete_package'),
    path('api-root/',views.api_root),
    path('api/<int:pk>/highlight/', views.APIHighlight.as_view()),
    path('api/',views.APIList.as_view(),name='api-list'),
    path('api/<int:pk>/',views.APIDetail.as_view(),name='api-detail'),
    path('api/<int:pk>/highlight/',views.APIHighlight.as_view(),name='api-highlight'),
    path('users/',views.UserList.as_view(),name='user-list'),
    path('users/<int:pk>/',views.UserDetail.as_view(),name='user-detail'),
]

urlpatterns = format_suffix_patterns(urlpatterns)
urlpatterns += [
    path('api-auth/',include('rest_framework.urls')),
]


if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL,document_root=settings.MEDIA_ROOT)