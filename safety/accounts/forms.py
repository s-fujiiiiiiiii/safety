from django.contrib.auth.forms import UserCreationForm
from .models import User
from django import forms

class SignUpForm(UserCreationForm):
    family_leader_flag = forms.BooleanField(required=False, label=)