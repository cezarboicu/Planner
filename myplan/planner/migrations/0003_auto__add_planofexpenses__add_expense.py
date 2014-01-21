# -*- coding: utf-8 -*-
from south.utils import datetime_utils as datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models


class Migration(SchemaMigration):

    def forwards(self, orm):
        # Adding model 'PlanOfExpenses'
        db.create_table(u'planner_planofexpenses', (
            (u'id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('name', self.gf('django.db.models.fields.CharField')(max_length=250)),
            ('description', self.gf('django.db.models.fields.CharField')(max_length=250)),
            ('date_of_creation', self.gf('django.db.models.fields.DateTimeField')(default=datetime.datetime.now)),
            ('user_of_plan', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['planner.UserMyPlan'])),
        ))
        db.send_create_signal('planner', ['PlanOfExpenses'])

        # Adding model 'Expense'
        db.create_table(u'planner_expense', (
            (u'id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('amount', self.gf('django.db.models.fields.IntegerField')()),
            ('type', self.gf('django.db.models.fields.CharField')(default='CASH', max_length=4)),
            ('date', self.gf('django.db.models.fields.DateTimeField')(default=datetime.datetime(2014, 1, 21, 0, 0))),
            ('details', self.gf('django.db.models.fields.CharField')(max_length=250, null=True, blank=True)),
            ('plan', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['planner.PlanOfExpenses'])),
        ))
        db.send_create_signal('planner', ['Expense'])


    def backwards(self, orm):
        # Deleting model 'PlanOfExpenses'
        db.delete_table(u'planner_planofexpenses')

        # Deleting model 'Expense'
        db.delete_table(u'planner_expense')


    models = {
        'planner.expense': {
            'Meta': {'object_name': 'Expense'},
            'amount': ('django.db.models.fields.IntegerField', [], {}),
            'date': ('django.db.models.fields.DateTimeField', [], {'default': 'datetime.datetime(2014, 1, 21, 0, 0)'}),
            'details': ('django.db.models.fields.CharField', [], {'max_length': '250', 'null': 'True', 'blank': 'True'}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'plan': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['planner.PlanOfExpenses']"}),
            'type': ('django.db.models.fields.CharField', [], {'default': "'CASH'", 'max_length': '4'})
        },
        'planner.planofexpenses': {
            'Meta': {'object_name': 'PlanOfExpenses'},
            'date_of_creation': ('django.db.models.fields.DateTimeField', [], {'default': 'datetime.datetime.now'}),
            'description': ('django.db.models.fields.CharField', [], {'max_length': '250'}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '250'}),
            'user_of_plan': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['planner.UserMyPlan']"})
        },
        'planner.usermyplan': {
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