from django.urls import path
from .views import CreateUserView
from .views import LoginView,UserListView

urlpatterns = [
    path('create_user/', CreateUserView.as_view(), name='create_user'),
    path('login/', LoginView.as_view(), name='login'),
    path('user_list/', UserListView.as_view(), name='user_list'),
]