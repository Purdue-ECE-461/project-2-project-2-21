from django.db import models
from django.conf import settings
from django.db.models.signals import post_save
from django.dispatch import receiver
from rest_framework.authtoken.models import Token
from rest_framework.authentication import TokenAuthentication
from datetime import datetime
from pygments.lexers import get_lexer_by_name
from pygments.formatters.html import HtmlFormatter
from pygments import highlight

# Create your models here.
class Package(models.Model):
    title = models.CharField(max_length=100)
    date = models.DateField(auto_now=True)
    uppackage = models.FileField(upload_to='upload/packages/')

    def __str__(self):
        return self.title

class GetAPI(models.Model):
    owner = models.ForeignKey('auth.User', related_name='apis', on_delete=models.CASCADE)
    highlighted = models.TextField(default='')
    metadata = models.JSONField()
    data = models.JSONField()
    
    def __str__(self):
        return self.title
    

@receiver(post_save, sender=settings.AUTH_USER_MODEL)
def create_auth_token(sender, instance=None, created=False, **kwargs):
    if created:
        Token.objects.create(user=instance)