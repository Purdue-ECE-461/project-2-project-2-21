from django.contrib.auth.models import User
from rest_framework import serializers
from .models import GetAPI



class APISerializer(serializers.HyperlinkedModelSerializer):
    owner = serializers.ReadOnlyField(source='owner.username')
    detail = serializers.HyperlinkedIdentityField(view_name='api-detail', format='html')
    class Meta:
        model = GetAPI
        fields = ['owner','detail','metadata','data']


class UserSerializer(serializers.ModelSerializer):
    apis = serializers.PrimaryKeyRelatedField(many=True,queryset=GetAPI.objects.all())
    class Meta:
        model = User
        fields = ['url','id','username','apis']



