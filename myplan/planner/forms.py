from django.forms import ModelForm
from planner.models.user_model import UserMyPlan


class FormUserMyPlan(ModelForm):
    class Meta:
        model = UserMyPlan
        fields = '__all__';