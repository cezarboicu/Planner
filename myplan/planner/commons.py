#file for declaring common stuff to use inside the project
from django.db import models

MALE = 'm'
FEMALE = 'f'
UNDEFINED = 'u'

SEX_TYPE = (
    (MALE,'FEMALE'),
    (FEMALE,'MALE'),
    (UNDEFINED,'UNDEFINED'),
)
