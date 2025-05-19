from django.http import HttpResponse
from django.urls import path

def health_check(request):
    return HttpResponse("ok")

urlpatterns = [
    path('health/', health_check, name='health_check'),
]
