from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from accounts.models import SimpleUser
from .models import SafetyStatus
import json
from typing import Optional

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


def _serialize_latest(record: Optional[SafetyStatus]):
    if record is None:
        return None
    return {
        "status": record.status,
        "memo": record.memo,
        "created_at": record.created_at,
    }


# ----------------------------
# 最新の安否取得（単体）
# GET /safetystatus/latest/?user_id=1
# ----------------------------
def latest_status(request):
    if request.method != "GET":
        return JsonResponse({"error": "GET メソッドを使用してください"}, status=405)

    user_id = request.GET.get("user_id")
    if not user_id:
        return JsonResponse({"error": "user_id is required"}, status=400)

    try:
        SimpleUser.objects.get(id=user_id)
    except SimpleUser.DoesNotExist:
        return JsonResponse({"error": "ユーザーが存在しません"}, status=404)

    record = (
        SafetyStatus.objects
        .filter(user_id=user_id)
        .order_by("-created_at")
        .first()
    )

    if record is None:
        return JsonResponse({"user_id": int(user_id), "latest": None}, status=200)

    return JsonResponse({
        "user_id": record.user_id,
        "latest": _serialize_latest(record),
    }, status=200)


# ----------------------------
# 最新の安否取得（一括）
# POST /safetystatus/latest_bulk/ {"user_ids": [1,2,3]}
# ----------------------------
@csrf_exempt
def latest_bulk(request):
    if request.method != "POST":
        return JsonResponse({"error": "POST メソッドを使用してください"}, status=405)

    try:
        data = json.loads(request.body or "{}")
    except Exception:
        return JsonResponse({"error": "invalid json"}, status=400)

    user_ids = data.get("user_ids")
    if not isinstance(user_ids, list) or not user_ids:
        return JsonResponse({"error": "user_ids is required"}, status=400)

    # 型の揺れ（文字列/数値）を吸収
    normalized_user_ids: list[int] = []
    for uid in user_ids:
        try:
            normalized_user_ids.append(int(uid))
        except Exception:
            continue

    if not normalized_user_ids:
        return JsonResponse({"error": "user_ids is required"}, status=400)

    # シンプルにユーザーごとに最新1件を取る（グループ規模が小さい想定）
    latest_by_user_id: dict[int, dict] = {}
    for uid in normalized_user_ids:
        record = (
            SafetyStatus.objects
            .filter(user_id=uid)
            .order_by("-created_at")
            .first()
        )
        latest_by_user_id[uid] = _serialize_latest(record)

    return JsonResponse({"latest": latest_by_user_id}, status=200)
