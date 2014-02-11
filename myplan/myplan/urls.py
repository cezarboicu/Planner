from django.conf.urls import patterns, include, url

from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    url(r'^$', 'planner.views.index_planner', name='index_planner'),
    url(r'^admin/', include(admin.site.urls)),
)
