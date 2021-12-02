"""This module manages hellapp urls"""

from django.urls import path, include

urlpatterns = [
    path('helloapp/', include('helloapp.urls')),
    path('', include('proj2site.urls')),
]
