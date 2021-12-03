"""This module handles django urls"""

from django.urls import path
import views

app_name = 'proj2site'
urlpatterns = [
    path('',views.index,name='index'),
    path('download/',views.download,name='download'),
]
