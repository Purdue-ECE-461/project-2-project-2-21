from django.contrib.auth.models import User
from django.contrib.auth.models import User
from rest_framework import serializers
from .models import GetAPI, metadata, data

class MetadataSerializer(serializers.ModelSerializer):
    class Meta:
        model = metadata
        fields = ['Name','Version','ID']

class DataSerializer(serializers.ModelSerializer):
    class Meta:
        model = data
        fields = ['Content','URL','JSProgram']

class APISerializer(serializers.HyperlinkedModelSerializer):
    owner = serializers.ReadOnlyField(source='owner.username')
    detail = serializers.HyperlinkedIdentityField(view_name='api-detail', format='html')
    metadata = MetadataSerializer(many=False)
    data = DataSerializer(many=False)
    class Meta:
        model = GetAPI
        fields = ['owner','detail','metadata','data']


class UserSerializer(serializers.HyperlinkedModelSerializer):
    apis = serializers.PrimaryKeyRelatedField(many=True,queryset=GetAPI.objects.all())
    class Meta:
        model = User
        fields = ['url','id','username','apis']



