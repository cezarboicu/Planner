from django.http import HttpResponse
from django.template import RequestContext, loader

def index_planner(request):
    template = loader.get_template('planner/index.html')
    context = RequestContext(request)
    return HttpResponse(template.render(context))