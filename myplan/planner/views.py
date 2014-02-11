from django.shortcuts import render
from django.http import HTTPResponse


def index_planner(request):
    return HTTPResponse('Welcome Please log in or sign up')