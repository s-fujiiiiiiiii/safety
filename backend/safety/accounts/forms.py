from django.contrib.auth.forms import UserCreationForm
from .models import User
from django import forms

class SignUpForm(UserCreationForm):
    email = forms.EmailField(required=True, label="メールアドレス")
    family_leader_flag = forms.BooleanField(
        required=False, label="家族代表者として登録"
        )
    
    class Meta:
        model = User
        fields = ["username", "email", "password1", "password2", "family_leader_flag"]