"""This module contains a class to configure the django site"""

from django.apps import AppConfig


class Proj2SiteConfig(AppConfig):
    """This class manages the django site configuration"""
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'proj2site'
