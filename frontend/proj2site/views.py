"""This module creates views for basic html responses"""

from django.shortcuts import render
# from django.http import HttpResponse

# Create your views here.
def index(request):
    """Renders request for index"""
    return render(request,'proj2site/index.html',{})

def download(request):
    """Renders request for download"""
    return render(request, 'proj2site/download.html',{})
