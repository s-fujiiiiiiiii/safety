from django.contrib import admin
from django.urls import path, include
from safetyapp.views import HomeView 

urlpatterns = [
    path('admin/', admin.site.urls),
    path('accounts/', include("accounts.urls")),
    path("", HomeView.as_view(), name="home"),
    path('safetystatus/', include('safetystatus.urls')),
    path('api/sns/', include('sns_analyzer.urls')),
    path('api/', include('accounts.urls')),
]
