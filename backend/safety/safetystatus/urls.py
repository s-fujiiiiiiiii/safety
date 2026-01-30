from django.urls import path
from . import views

urlpatterns = [
    path('register/', views.register_status, name='register_status'),
    path('latest/', views.latest_status, name='latest_status'),
    path('latest_bulk/', views.latest_bulk, name='latest_bulk'),
]
