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
        is_group_leader = request.data.get("is_group_leader", False)

        if not name or not raw_pw:
            return Response({"message": "名前とパスワードは必須です"}, status=400)

        if SimpleUser.objects.filter(name=name).exists():
            return Response({"message": "このユーザー名は既に使われています"}, status=400)

        user = SimpleUser.objects.create(
            name=name,
            password=make_password(raw_pw),
            is_group_leader=is_group_leader,
        )

        return Response(
            {"message": "ユーザー作成成功", "user_id": user.id},
            status=201
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
            return Response({"message": "名前またはパスワードが違います"}, status=401)

        if not check_password(password, user.password):
            return Response({"message": "名前またはパスワードが違います"}, status=401)

        return Response({
            "user_id": user.id,
            "is_group_leader": user.is_group_leader,
        })


# ----------------------------
# グループ作成（リーダー）
# ----------------------------
class CreateGroupView(APIView):
    def post(self, request):
        user_id = request.data.get("user_id")
        group_name = request.data.get("group_name")

        if not user_id or not group_name:
            return Response({"message": "必須項目不足"}, status=400)

        try:
            user = SimpleUser.objects.get(id=user_id)
        except SimpleUser.DoesNotExist:
            return Response({"message": "ユーザーが存在しません"}, status=404)

        group = Group.objects.create(name=group_name)

        # 作成者をリーダーとして参加させる
        user.groups.add(group)
        user.is_group_leader = True
        user.save()

        return Response({
            "message": "グループ作成成功",
            "group_id": group.id,
            "invite_code": group.invite_code,
        })


# ----------------------------
# グループ一覧
# ----------------------------
class GroupListView(APIView):
    def get(self, request):
        user_id = request.GET.get("user_id")

        if not user_id:
            return Response({"message": "user_id is required"}, status=400)

        groups = Group.objects.filter(simpleuser__id=user_id)

        return Response([
            {"id": g.id, "name": g.name, "invite_code": g.invite_code}
            for g in groups
        ])


# ----------------------------
# グループメンバー一覧
# ----------------------------
class GroupMemberListView(APIView):
    def get(self, request):
        group_id = request.GET.get("group_id")

        if not group_id:
            return Response({"message": "group_id is required"}, status=400)

        try:
            group = Group.objects.get(id=group_id)
        except Group.DoesNotExist:
            return Response({"message": "グループが存在しません"}, status=404)

        members = SimpleUser.objects.filter(groups=group)

        return Response([
            {
                "id": u.id,
                "name": u.name,
                "is_group_leader": u.is_group_leader,
            }
            for u in members
        ])


# ----------------------------
# 招待コードで参加
# ----------------------------
class JoinGroupView(APIView):
    def post(self, request):
        user_id = request.data.get("user_id")
        invite_code = request.data.get("invite_code")

        try:
            user = SimpleUser.objects.get(id=user_id)
            group = Group.objects.get(invite_code=invite_code)
        except:
            return Response({"message": "参加失敗"}, status=404)

        user.groups.add(group)

        return Response({"message": "参加しました"})


# ----------------------------
# メンバー削除（リーダーのみ）
# ----------------------------
class RemoveGroupMemberView(APIView):
    def post(self, request):
        leader_id = request.data.get("leader_id")
        group_id = request.data.get("group_id")
        target_user_id = request.data.get("target_user_id")

        try:
            leader = SimpleUser.objects.get(id=leader_id)
            target = SimpleUser.objects.get(id=target_user_id)
            group = Group.objects.get(id=group_id)
        except:
            return Response({"message": "データが存在しません"}, status=404)

        if not leader.is_group_leader:
            return Response({"message": "権限なし"}, status=403)

        if leader.id == target.id:
            return Response({"message": "自分は削除できません"}, status=400)

        target.groups.remove(group)

        return Response({"message": "削除しました"})
