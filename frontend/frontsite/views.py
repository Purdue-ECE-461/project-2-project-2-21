from django.shortcuts import redirect, render, redirect
from django.core.files.storage import FileSystemStorage
from django.views import generic
from django.views.generic import ListView, CreateView, DeleteView
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.views import LoginView
from django.contrib import messages
from django.views.generic.base import TemplateView
from django.contrib.auth.decorators import login_required

from django_filters.rest_framework import DjangoFilterBackend

from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.parsers import JSONParser
from rest_framework.views import APIView
from rest_framework.reverse import reverse
from rest_framework.authtoken.views import ObtainAuthToken
from rest_framework.authtoken.models import Token
from rest_framework import status, generics, permissions, renderers, filters
import requests

from .forms import PackageForm, createUserForm
from .models import Package, GetAPI
from .serializers import APISerializer, UserSerializer
from .permissions import IsOwnerOrReadOnly

# Create your views here.
def index(request):
    return render(request,'frontsite/index.html',{})

class login(LoginView):
    template_name = 'frontsite/login.html'

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
    filter_backends = [filters.SearchFilter]
    search_fields = ['metadata__Name', 'metadata__Version','metadata__ID']
    def perform_create(self,serializer):
        serializer.save(owner=self.request.user)

class APIDetail(generics.RetrieveUpdateDestroyAPIView):
    queryset = GetAPI.objects.all()
    serializer_class = APISerializer
    filter_backends = [filters.SearchFilter]
    search_fields = ['=metadata__Name', '=metadata__Version','=metadata__ID']
    permission_classes = [permissions.IsAuthenticatedOrReadOnly,IsOwnerOrReadOnly] 

class APIHighlight(generics.GenericAPIView):
    queryset = GetAPI.objects.all()
    renderer_classes = [renderers.StaticHTMLRenderer]

    def get(self, request, *args, **kwargs):
        api = self.get_object()
        return Response(api.highlighted)

class UserList(generics.ListCreateAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
class UserDetail(generics.RetrieveUpdateDestroyAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

@api_view(['GET'])
def api_root(request, format=None):
    return Response({
        'users': reverse('user-list', request=request, format=format),
        'apis': reverse('api-list', request=request, format=format)
    })

class CustomAuthToken(ObtainAuthToken):
    def post(self,request,*args,**kwargs):
        serializer = self.serializer_class(data=request.data,context={'request',request})
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data['user']
        token, created = Token.objects.get_or_create(user=user)
        return Response({
            'token': token.key,
            'user_id': user.pk,
        })

