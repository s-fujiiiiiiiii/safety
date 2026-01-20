from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny

from django.contrib.auth.hashers import make_password, check_password

from .models import SimpleUser, Group
from .serializers import SimpleUserSerializer


# ----------------------------
# ユーザー作成
# ----------------------------
class CreateUserView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        name = request.data.get("name")
        raw_pw = request.data.get("password")

        is_admin = request.data.get("is_admin", False)
        is_group_leader = request.data.get("is_group_leader", False)

        if not name or not raw_pw:
            return Response(
                {"message": "名前とパスワードは必須です"},
                status=status.HTTP_400_BAD_REQUEST
            )

        if SimpleUser.objects.filter(name=name).exists():
            return Response(
                {"message": "このユーザー名は既に使われています"},
                status=status.HTTP_400_BAD_REQUEST
            )

        user = SimpleUser.objects.create(
            name=name,
            password=make_password(raw_pw),
            is_admin=is_admin,
            is_group_leader=is_group_leader,
        )

        return Response(
            {
                "message": "ユーザー作成成功",
                "user_id": user.id,
            },
            status=status.HTTP_201_CREATED
        )


# ----------------------------
# ログイン
# ----------------------------
class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        name = request.data.get("name")
        password = request.data.get("password")

        try:
            user = SimpleUser.objects.get(name=name)
        except SimpleUser.DoesNotExist:
            return Response(
                {"message": "名前またはパスワードが違います"},
                status=status.HTTP_401_UNAUTHORIZED
            )

        if not check_password(password, user.password):
            return Response(
                {"message": "名前またはパスワードが違います"},
                status=status.HTTP_401_UNAUTHORIZED
            )

        return Response(
            {
                "message": "ログイン成功",
                "user_id": user.id,
                "is_admin": user.is_admin,
                "is_group_leader": user.is_group_leader,
            },
            status=status.HTTP_200_OK
        )


# ----------------------------
# ユーザー一覧（管理者用）
# ----------------------------
class UserListView(APIView):
    def get(self, request):
        users = SimpleUser.objects.all().order_by("id")
        serializer = SimpleUserSerializer(users, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)


# ----------------------------
# グループ作成（管理者）
# ----------------------------
class CreateGroupView(APIView):
    def post(self, request):
        user_id = request.data.get("user_id")
        group_name = request.data.get("group_name")

        if not user_id or not group_name:
            return Response(
                {"message": "user_id と group_name は必須です"},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            user = SimpleUser.objects.get(id=user_id)
        except SimpleUser.DoesNotExist:
            return Response(
                {"message": "ユーザーが存在しません"},
                status=status.HTTP_404_NOT_FOUND
            )

        if not user.is_admin:
            return Response(
                {"message": "管理者のみ作成できます"},
                status=status.HTTP_403_FORBIDDEN
            )

        group = Group.objects.create(name=group_name)

        # ★ ここがないと一覧に出ない
        user.groups.add(group)
        user.is_group_leader = True
        user.save()

        return Response(
            {
                "message": "グループ作成成功",
                "group_id": group.id,
                "invite_code": group.invite_code,
            },
            status=status.HTTP_201_CREATED
        )


# ----------------------------
# グループ一覧取得
# ----------------------------
class GroupListView(APIView):
    def get(self, request):
        user_id = request.GET.get("user_id")

        if not user_id:
            return Response(
                {"message": "user_id is required"},
                status=status.HTTP_400_BAD_REQUEST
            )

        groups = Group.objects.filter(simpleuser__id=user_id)

        data = []
        for g in groups:
            data.append({
                "id": g.id,
                "name": g.name,
                "invite_code": g.invite_code,
            })

        return Response(data, status=status.HTTP_200_OK)
    
class GroupMemberListView(APIView):
    def get(self, request):
        group_id = request.GET.get("group_id")

        if not group_id:
            return Response(
                {"message": "group_id is required"},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            group = Group.objects.get(id=group_id)
        except Group.DoesNotExist:
            return Response(
                {"message": "グループが存在しません"},
                status=status.HTTP_404_NOT_FOUND
            )

        members = SimpleUser.objects.filter(groups=group)

        data = []
        for user in members:
            data.append({
                "id": user.id,
                "name": user.name,
                "is_admin": user.is_admin,
                "is_group_leader": user.is_group_leader,
            })

        return Response(data, status=status.HTTP_200_OK)


# ----------------------------
# 招待コードでグループ参加
# ----------------------------
class JoinGroupView(APIView):
    def post(self, request):
        user_id = request.data.get("user_id")
        invite_code = request.data.get("invite_code")

        if not user_id or not invite_code:
            return Response(
                {"message": "user_id と invite_code は必須です"},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            user = SimpleUser.objects.get(id=user_id)
            group = Group.objects.get(invite_code=invite_code)
        except SimpleUser.DoesNotExist:
            return Response({"message": "ユーザーが存在しません"}, status=404)
        except Group.DoesNotExist:
            return Response({"message": "招待コードが無効です"}, status=404)

        user.groups.add(group)

        return Response(
            {"message": "グループに参加しました"},
            status=status.HTTP_200_OK
        )

class GroupMemberRemoveView(APIView):
    def post(self, request):
        group_id = request.data.get("group_id")
        leader_id = request.data.get("leader_id")
        target_user_id = request.data.get("target_user_id")

        if not group_id or not leader_id or not target_user_id:
            return Response(
                {"message": "必要なパラメータが不足しています"},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            leader = SimpleUser.objects.get(id=leader_id)
            target_user = SimpleUser.objects.get(id=target_user_id)
            group = Group.objects.get(id=group_id)
        except (SimpleUser.DoesNotExist, Group.DoesNotExist):
            return Response(
                {"message": "データが存在しません"},
                status=status.HTTP_404_NOT_FOUND
            )

        # ★ リーダー判定
        if not leader.is_group_leader:
            return Response(
                {"message": "権限がありません"},
                status=status.HTTP_403_FORBIDDEN
            )

        # ★ 自分自身は削除不可
        if leader.id == target_user.id:
            return Response(
                {"message": "自分自身は削除できません"},
                status=status.HTTP_400_BAD_REQUEST
            )

        # ★ グループから削除
        target_user.groups.remove(group)

        return Response(
            {"message": "メンバーを削除しました"},
            status=status.HTTP_200_OK
        )