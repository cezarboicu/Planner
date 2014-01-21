from django.contrib import admin
from planner.models import UserMyPlan, Expense, PlanOfExpenses
# Register your models here.

admin.site.register(UserMyPlan)
admin.site.register(Expense)
admin.site.register(PlanOfExpenses)