from django.db import models
from user_model import UserMyPlan
from django.utils import timezone

class PlanOfExpenses(models.Model):
    name = models.CharField(max_length=250)
    description = models.CharField(max_length=250)
    date_of_creation = models.DateTimeField(default=timezone.now)
    user_of_plan = models.ForeignKey(UserMyPlan)
    class Meta:
        app_label = 'planner'