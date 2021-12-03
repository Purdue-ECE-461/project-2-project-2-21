from django.db import models

# Create your models here.
class Package(models.Model):
    title = models.CharField(max_length=100)
    uppackage = models.FileField(upload_to='upload/packages/')

    def __str__(self):
        return self.title