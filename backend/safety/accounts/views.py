from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny
from django.contrib.auth.hashers import make_password
from .serializers import SimpleUserSerializer
from django.contrib.auth import authenticate
from .models import SimpleUser
from .serializers import SimpleUserSerializer

class CreateUserView(APIView):
    permission_classes = [AllowAny]  # 誰でもアクセスOK

    def post(self, request):
        data = request.data.copy()
        raw_pw = data.get('password', '')
        data['password'] = make_password(raw_pw)  # パスワードをハッシュ化
        serializer = SimpleUserSerializer(data=data)

        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        name = request.data.get("name")
        password = request.data.get("password")

        from .models import SimpleUser

        try:
            user = SimpleUser.objects.get(name=name)
        except SimpleUser.DoesNotExist:
            return Response({"message": "名前またはパスワードが違います"}, status=401)

        # パスワードチェック（ハッシュ対応）
        from django.contrib.auth.hashers import check_password
        if check_password(password, user.password):
            return Response({"message": "ログイン成功", "user_id": user.id}, status=200)
        else:
            return Response({"message": "名前またはパスワードが違います"}, status=401)

class UserListView(APIView):
    def get(self, request):
        users = SimpleUser.objects.all().order_by('id')
        serializer = SimpleUserSerializer(users, many=True)
        return Response(serializer.data, status=200)