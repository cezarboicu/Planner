from django.db import models
from django.utils import timezone
from plan_model import PlanOfExpenses

PAYMENT_TYPE = (
    ('CASH', 'cash'),
    ('CARD', 'card')
)
class Expense(models.Model):
    amount = models.IntegerField()
    type = models.CharField(max_length=4, choices=PAYMENT_TYPE, default='CASH')
    date = models.DateTimeField(default=timezone.now())
    details = models.CharField(max_length=250, blank=True, null=True)
    plan = models.ForeignKey(PlanOfExpenses)
    class Meta:
        app_label = 'planner'