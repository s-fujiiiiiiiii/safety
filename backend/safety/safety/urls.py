from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('accounts/', include("accounts.urls")),
    path("", HomeView.as_view(), name="home"),
    path('api/sns/', include('sns_analyzer.urls')),
    path('api/', include('accounts.urls')),
]
