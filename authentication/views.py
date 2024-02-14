from django.shortcuts import render

def login_view(request):
    # login logic
    return render(request, 'login-auth/login.html')
