from django.shortcuts import redirect, render, redirect
from django.core.files.storage import FileSystemStorage
from django.views.generic import ListView, CreateView, DeleteView
from .forms import PackageForm
from .models import Package

# Create your views here.
def index(request):
    return render(request,'frontsite/index.html',{})

#package upload class based
class PackageListView(ListView):
    model = Package
    template_name = 'fronsite/package_list.html'
    context_object_name = 'packages'

class UploadPackageView(CreateView):
    model = Package
    fields = ('title','uppackage')
    success_url = '/packages/'
    template_name = 'frontsite/upload_package.html'

#package deletion
class DeletePackageView(DeleteView):
    model = Package
    success_url = '/packages/'

def download(request):
    return render(request,'frontsite/download.html',{})