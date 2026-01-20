from django.db import models
from django.conf import settings   # ← これが重要！ユーザーモデルの参照に使う

class SafetyStatus(models.Model):
    # Django のユーザーモデルを正しく参照
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    memo = models.TextField(blank=True, null=True)
    status = models.CharField(max_length=50)  # 例: "無事", "怪我", "危険"
    location = models.CharField(max_length=255, blank=True, null=True)  # 位置情報担当から受け取る想定
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user} - {self.status} - {self.created_at}"
    
    