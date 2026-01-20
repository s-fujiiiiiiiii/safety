from django.db import models
import random
import string


from django.db import models
import random
import string


def generate_invite_code():
    return ''.join(random.choices(string.digits, k=6))


class Group(models.Model):
    name = models.CharField(max_length=100)
    invite_code = models.CharField(
        max_length=6,
        unique=True,
        default=generate_invite_code
    )
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.name} ({self.invite_code})"


class SimpleUser(models.Model):
    name = models.CharField(max_length=100, unique=True)
    password = models.CharField(max_length=255)

    is_admin = models.BooleanField(default=False)
    is_group_leader = models.BooleanField(default=False)

    groups = models.ManyToManyField(Group, blank=True)

    def __str__(self):
        return self.name
