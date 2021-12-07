from django.shortcuts import redirect, render, redirect
from django.core.files.storage import FileSystemStorage
from django.views import generic
from django.views.generic import ListView, CreateView, DeleteView
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User
from django.contrib.auth import authenticate, login, logout
from django.contrib import messages
from django.views.generic.base import TemplateView

from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.parsers import JSONParser
from rest_framework.views import APIView
from rest_framework.reverse import reverse
from rest_framework import status, generics, permissions, renderers
import requests

from .forms import PackageForm, createUserForm
from .models import Package, GetAPI
from .serializers import APISerializer, UserSerializer
from .permissions import IsOwnerOrReadOnly

# Create your views here.
def index(request):
    return render(request,'frontsite/index.html',{})

def login(request):
    return render(request, 'frontsite/login.html',{})

def register(request):
    form = createUserForm()
    if request.method == 'POST':
        form = createUserForm(request.POST)
        if form.is_valid():
            form.save()
            user = form.cleaned_data.get('username')
            messages.success(request, 'Account was created for ' + user)
            return redirect('login')
    context = {'form' : form}
    return render(request, 'frontsite/register.html',context)


class APIList(generics.ListCreateAPIView):
    queryset = GetAPI.objects.all()
    serializer_class = APISerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    def perform_create(self,serializer):
        serializer.save(owner=self.request.user)

class APIDetail(generics.RetrieveUpdateDestroyAPIView):
    queryset = GetAPI.objects.all()
    serializer_class = APISerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly,IsOwnerOrReadOnly] 

class UserList(generics.ListAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer

class UserDetail(generics.RetrieveAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer

@api_view(['GET'])
def api_root(request, format=None):
    return Response({
        'users': reverse('user-list', request=request, format=format),
        'apis': reverse('api-list', request=request, format=format)
    })

class APIHighlight(generics.GenericAPIView):
    queryset = GetAPI.objects.all()
    renderer_classes = [renderers.StaticHTMLRenderer]

    def get(self, request, *args, **kwargs):
        api = self.get_object()
        return Response(api.highlighted)

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
