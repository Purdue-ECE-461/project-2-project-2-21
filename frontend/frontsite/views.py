from django.shortcuts import redirect, render, redirect
from django.core.files.storage import FileSystemStorage
from .forms import PackageForm
from .models import Package

# Create your views here.
def index(request):
    return render(request,'frontsite/index.html',{})

def upload(request):
    context = {}
    if request.method == 'POST':
        uploaded_file = request.FILES['document']
        fs = FileSystemStorage()
        name = fs.save(uploaded_file.name, uploaded_file)
        context['url'] = fs.url(name)
    return render(request,'frontsite/upload.html',context)

def package_list(request):
    packages = Package.objects.all()
    return render(request, 'frontsite/package_list.html', {
        'packages': packages
    })

def upload_package(request):
    if request.method == 'POST':
        form = PackageForm(request.POST, request.FILES)
        if form.is_valid():
            form.save()
            return redirect('package_list')
    else:
        form = PackageForm()
    return render(request, 'frontsite/upload_package.html', {
        'form': form
    })

def download(request):
    return render(request,'frontsite/download.html',{})