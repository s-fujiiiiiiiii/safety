from django.urls import path
from .views import CreateUserView
from .views import LoginView,UserListView
from .views import CreateGroupView
from .views import JoinGroupView
from .views import GroupListView
from .views import GroupMemberListView
from .views import GroupMemberRemoveView

urlpatterns = [
    path('create_user/', CreateUserView.as_view(), name='create_user'),
    path('login/', LoginView.as_view(), name='login'),
    path('user_list/', UserListView.as_view(), name='user_list'),
    path("create_group/", CreateGroupView.as_view()),
    path("join_group/", JoinGroupView.as_view()),
    path("groups/", GroupListView.as_view()),
    path("group_list/", GroupListView.as_view()),  
    path("group_members/", GroupMemberListView.as_view()),
    path("group_member_remove/", GroupMemberRemoveView.as_view()),
]