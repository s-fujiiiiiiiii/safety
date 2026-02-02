from django.urls import path
from .views import NearbyShelterView

urlpatterns = [
    path('', NearbyShelterView.as_view()),
]
