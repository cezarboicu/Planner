#The class User holds any user which is creating an account
#The user has a certain amount of privileges which can grant him certain rights / features

from django.db import models
from planner.commons import SEX_TYPE
from datetime import datetime

class UserMyPlan(models.Model):
    name = models.CharField(max_length=50)
    surname = models.CharField(max_length=50)
    date_of_birth = models.DateField()
    date_joined = models.DateTimeField(datetime.now())
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=100)
    sex = models.CharField(max_length=1, choices=SEX_TYPE, default='UNDEFINED')
    class Meta:
        app_label = 'planner'