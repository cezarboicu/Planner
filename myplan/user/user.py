#The class User holds any user which is creating an account
#The user has a certain amount of privileges which can grant him certain rights / features

from django.db import models

class User:
    name = models.CharField(max_length=50)
    surname = models.CharField(max_length=50)
    date_of_birth = models.DateField()
    date_joined = models.DateTimeField()
    email = models.EmailField()
    password = models.CharField(max_length=100)
    sex = 
    def __init__(self):
        pass

