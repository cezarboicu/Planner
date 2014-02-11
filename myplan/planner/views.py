from django.http import HttpResponse


def index_planner(request):
    return HttpResponse('Welcome Please log in or sign up')