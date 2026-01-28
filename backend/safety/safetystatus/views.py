from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from accounts.models import SimpleUser
from .models import SafetyStatus
import json

@csrf_exempt
def register_status(request):
    if request.method == "POST":
        try:
            data = json.loads(request.body)

            user_id = data.get("user_id")
            status = data.get("status")
            memo = data.get("memo", "") 

            #ユーザー取得
            try:
                user = SimpleUser.objects.get(id=user_id)
            except SimpleUser.DoesNotExist:
                return JsonResponse({"error": "ユーザーが存在しません"}, status=400)

            #データ保存
            record = SafetyStatus.objects.create(
                user=user,
                status=status,
                memo=memo
            )

            return JsonResponse({
                "message": "安否登録が完了しました",
                "id": record.id,
                "status": record.status,
                "memo": record.memo,
                "created_at": record.created_at
            })

        except Exception as e:
            return JsonResponse({"error": str(e)}, status=400)

    return JsonResponse({"error": "POST メソッドを使用してください"}, status=405)
