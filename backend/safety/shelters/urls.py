from django.urls import path
from .views import ShelterListView

urlpatterns = [
    path('', ShelterListView.as_view()),
]
