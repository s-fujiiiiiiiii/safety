# sns_analyzer/urls.py
from django.urls import path
from .views import ShelterStatusView

urlpatterns = [
    path('', ShelterStatusView.as_view(), name='shelter_status'),
]
