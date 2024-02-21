from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login
from django.contrib.auth.decorators import login_required
from django.http import HttpResponse

def login_view(request):
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        
        # Authenticate user
        user = authenticate(request, username=username, password=password)
        
        if user is not None:
            # Log in the user
            login(request, user)
            # Redirect to a dashboard or home page
            return redirect('home')  # Basically the home page
        else:
            # Authentication failed, render login page with error message
            return render(request, 'login-auth/login.html', {'error_message': 'Invalid credentials'})
    else:
        # Render the login page for GET requests
        return render(request, 'login-auth/login.html')

@login_required
def dashboard_view(request):
    # This view is now secured and can only be accessed by logged-in users
    return render(request, 'dashboard-sandbox/dashboard.html')


def start_chatbot(request):
    if request.method == 'POST':
        participant_id = request.POST.get('participant_id')
        chatbot_group = request.POST.get('chatbot_group')

        # This will perform a logic to start the chatbot with the provided participant ID and chatbot group

        # Our dummy response for now
        return HttpResponse(f'Starting chatbot for Participant ID {participant_id} in Group {chatbot_group}')
    else:
        return HttpResponse('Only POST requests are allowed.')