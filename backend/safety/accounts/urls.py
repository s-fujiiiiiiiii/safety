from django.urls import path
from .views import (
    CreateUserView,
    LoginView,
    CreateGroupView,
    JoinGroupView,
    GroupListView,
    GroupMemberListView,
    RemoveGroupMemberView,
)

urlpatterns = [
    path('create_user/', CreateUserView.as_view(), name='create_user'),
    path('login/', LoginView.as_view(), name='login'),
    path("create_group/", CreateGroupView.as_view()),
    path("join_group/", JoinGroupView.as_view()),
    path("groups/", GroupListView.as_view()),
    path("group_list/", GroupListView.as_view()),
    path("group_members/", GroupMemberListView.as_view()),
    path("remove_group_member/", RemoveGroupMemberView.as_view()),
]
