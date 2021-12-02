"""This module gets service views from OS"""

import os
from django.shortcuts import render


def homepage(request):
    """Retrieves homepage"""
    service = os.environ.get('K_SERVICE', 'Unknown service')
    revision = os.environ.get('K_REVISION', 'Unknown revision')

    return render(request, 'homepage.html', context={
        "message": "It's running!",
        "Service": service,
        "Revision": revision,
    })

def aboutpage(request):
    """Retrieves aboutpage"""
    return render(request, 'aboutpage.html', context={})
