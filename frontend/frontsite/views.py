from django.shortcuts import redirect, render, redirect
from django.core.files.storage import FileSystemStorage
from django.views.generic import ListView, CreateView
from .forms import PackageForm
from .models import Package

# Create your views here.
def index(request):
    return render(request,'frontsite/index.html',{})

#inital upload test
def upload(request):
    context = {}
    if request.method == 'POST':
        uploaded_file = request.FILES['document']
        fs = FileSystemStorage()
        name = fs.save(uploaded_file.name, uploaded_file)
        context['url'] = fs.url(name)
    return render(request,'frontsite/upload.html',context)

#package upload
# def package_list(request):
#     packages = Package.objects.all()
#     return render(request, 'frontsite/package_list.html', {
#         'packages': packages
#     })

# def upload_package(request):
#     if request.method == 'POST':
#         form = PackageForm(request.POST, request.FILES)
#         if form.is_valid():
#             form.save()
#             return redirect('package_list')
#     else:
#         form = PackageForm()
#     return render(request, 'frontsite/upload_package.html', {
#         'form': form
#     })

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

def download(request):
    return render(request,'frontsite/download.html',{})