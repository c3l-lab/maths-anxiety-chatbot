from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login
from django.contrib.auth.decorators import login_required
from django.http import HttpResponse, HttpResponseBadRequest
from django.utils import timezone
from chatbot.models import ParticipantConversation
from chatbot.utils.chatbot_messages import get_initial_messages
from django.db import IntegrityError
from django.core.exceptions import ValidationError

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
    if request.method != 'POST':
        return HttpResponse('Only POST requests are allowed.', status=405)

    participant_id = request.POST.get('participant_id')
    chatbot_group = request.POST.get('chatbot_group')

    # Validate request data
    if not participant_id or not chatbot_group:
        return HttpResponseBadRequest('Missing participant ID or chatbot group.')

    if chatbot_group not in ['Group A - Helpful Chatbot', 'Group B - Neutral Chatbot']:
        return HttpResponseBadRequest('Invalid chatbot group specified.')

    try:
        participant, created = ParticipantConversation.objects.get_or_create(
            participant_id=participant_id,
            defaults={'chatbot_type': chatbot_group, 'chatbot_conversation': []}
        )

        initial_messages = get_initial_messages(chatbot_group)
        
        if participant.chatbot_conversation is None:
            participant.chatbot_conversation = initial_messages
        else:
            participant.chatbot_conversation.extend(initial_messages)
        
        participant.save()

    except IntegrityError as e:
        # Handle unique constraint violations, etc.
        return HttpResponseBadRequest('Database integrity error: ' + str(e))
    except ValidationError as e:
        # Handle validation errors from the model
        return HttpResponseBadRequest('Validation error: ' + str(e))
    except Exception as e:
        # Catch-all for any other exceptions
        return HttpResponseBadRequest('An unexpected error occurred: ' + str(e))

    return HttpResponse(f'Starting chatbot for Participant ID {participant_id} in Group {chatbot_group}')