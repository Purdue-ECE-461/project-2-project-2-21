from django.db import models
from datetime import datetime

# Create your models here.
class Package(models.Model):
    title = models.CharField(max_length=100)
    date = models.DateField(auto_now=True)
    uppackage = models.FileField(upload_to='upload/packages/')

    def __str__(self):
        return self.title