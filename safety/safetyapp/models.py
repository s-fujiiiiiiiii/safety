from django.db import models
from django.contrib.auth.models import User

class Friendship(models.Model):
    user = models.ForeignKey(User,on_delete=models.CASCADE,related_name="member")

    member = models.ForeignKey(User,on_delete=models.CASCADE,related_name="member_of")

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('user','member')

    def __str__(self):
        return f"{self.user} ↔ {self.member}"

class Notification(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="notifications")
    message = models.CharField(max_length=255)
    link = models.CharField(max_length=255, blank=True, null=True)
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user}: {self.message}"

