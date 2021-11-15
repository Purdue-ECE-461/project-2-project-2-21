from django.shortcuts import render
# from django.http import HttpResponse

# Create your views here.
def index(request):
    return render(request,'proj2site/index.html',{})

def download(request):
    return render(request, 'proj2site/download.html',{})