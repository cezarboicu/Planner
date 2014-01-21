# -*- coding: utf-8 -*-
from south.utils import datetime_utils as datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models


class Migration(SchemaMigration):

    def forwards(self, orm):
        # Adding model 'UserMyPlan'
        db.create_table(u'planner_usermyplan', (
            (u'id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('name', self.gf('django.db.models.fields.CharField')(max_length=50)),
            ('surname', self.gf('django.db.models.fields.CharField')(max_length=50)),
            ('date_of_birth', self.gf('django.db.models.fields.DateField')()),
            ('date_joined', self.gf('django.db.models.fields.DateTimeField')()),
            ('email', self.gf('django.db.models.fields.EmailField')(max_length=75)),
            ('password', self.gf('django.db.models.fields.CharField')(max_length=100)),
            ('sex', self.gf('django.db.models.fields.CharField')(default='UNDEFINED', max_length=1)),
        ))
        db.send_create_signal(u'planner', ['UserMyPlan'])


    def backwards(self, orm):
        # Deleting model 'UserMyPlan'
        db.delete_table(u'planner_usermyplan')


    models = {
        u'planner.usermyplan': {
            'Meta': {'object_name': 'UserMyPlan'},
            'date_joined': ('django.db.models.fields.DateTimeField', [], {}),
            'date_of_birth': ('django.db.models.fields.DateField', [], {}),
            'email': ('django.db.models.fields.EmailField', [], {'max_length': '75'}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '50'}),
            'password': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'sex': ('django.db.models.fields.CharField', [], {'default': "'UNDEFINED'", 'max_length': '1'}),
            'surname': ('django.db.models.fields.CharField', [], {'max_length': '50'})
        }
    }

    complete_apps = ['planner']