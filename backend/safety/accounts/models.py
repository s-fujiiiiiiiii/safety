from django.db import models

class SimpleUser(models.Model):
    name = models.CharField(max_length=100, blank=True)
    password = models.CharField(max_length=100, blank=True)
    create_at = models.DateTimeField(auto_now_add=True)
    is_admin = models.BooleanField(default=False) 
    def __str__(self):
        return self.name
