from django.contrib.auth.models import User
from rest_framework import serializers
from .models import GetAPI

class APISerializer(serializers.HyperlinkedModelSerializer):
    owner = serializers.ReadOnlyField(source='owner.username')
    highlight = serializers.HyperlinkedIdentityField(view_name='api-highlight', format='html')

    class Meta:
        model = GetAPI
        fields = ['owner','highlight','metadata','data']


class UserSerializer(serializers.HyperlinkedModelSerializer):
    api = serializers.HyperlinkedRelatedField(many=True, view_name='api-detail', read_only=True)

    class Meta:
        model = User
        fields = ['url', 'id', 'username', 'api']



