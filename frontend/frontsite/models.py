from django.db import models
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

def save(self, *args, **kwargs):
    lexer = get_lexer_by_name(self.language)
    linenos = 'table' if self.linenos else False
    options = {'title': self.title} if self.title else {}
    formatter = HtmlFormatter(style=self.style, linenos=linenos,
                              full=True, **options)
    self.highlighted = highlight(self.code, lexer, formatter)
    super(Snippet, self).save(*args, **kwargs)