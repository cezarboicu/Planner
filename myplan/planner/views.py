from django.shortcuts import render

def index_planner(request):
    return render(request, 'planner/index.html')

def login_planner(request):
    pass