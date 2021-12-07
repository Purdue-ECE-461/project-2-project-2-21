from django import forms
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User
from .models import Package

class PackageForm(forms.ModelForm):
    class Meta:
        model = Package
        fields = ('title','uppackage')

class createUserForm(UserCreationForm):
    class Meta:
        model = User
        fields = ['username', 'password1', 'password2']