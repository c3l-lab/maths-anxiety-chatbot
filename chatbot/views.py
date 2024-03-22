from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from django.core.exceptions import ValidationError
from django.db import IntegrityError
from django.http import HttpResponse, HttpResponseBadRequest, JsonResponse
from django.shortcuts import get_object_or_404, redirect, render
from django.utils import timezone

from chatbot.models import ParticipantConversation
from chatbot.utils.chatbot_messages import get_initial_messages

from .models import ParticipantConversation


# View for handling chatbot interactions
def chat(request):
    if request.method == "POST":
        message_text = (
            request.POST.get("message").strip().lower()
        )  # Normalize the input
        participant_id = request.POST.get("participant_id")

        participant = get_object_or_404(
            ParticipantConversation, participant_id=participant_id
        )

        # Append the user's message to the conversation
        user_message = {
            "type": "User",
            "message": message_text,
            "timestamp": timezone.now().isoformat(),
        }
        participant.chatbot_conversation.append(user_message)

        # Decide the chatbot's response based on the user's message
        if message_text == "yes":
            chatbot_response_text = "Great! Here's what you can do next: [provide next step or information]."
        elif message_text == "no":
            chatbot_response_text = (
                "Understood. Feel free to ask me anything else or say 'end' to finish."
            )
        else:
            # Fallback if the user's response doesn't match expected options
            chatbot_response_text = (
                "I didn't catch that. Could you please respond with 'Yes' or 'No'?"
            )

        chatbot_response = {
            "type": "Chatbot",
            "message": chatbot_response_text,
            "timestamp": timezone.now().isoformat(),
        }
        participant.chatbot_conversation.append(chatbot_response)

        participant.save()

        return JsonResponse({"message": chatbot_response_text})
    else:
        return HttpResponse("This endpoint supports only POST requests.")


def login_view(request):
    if request.method == "POST":
        username = request.POST.get("username")
        password = request.POST.get("password")

        # Authenticate user
        user = authenticate(request, username=username, password=password)

        if user is not None:
            # Log in the user
            login(request, user)
            # Redirect to a dashboard or home page
            return redirect("home")  # Basically the home page
        else:
            # Authentication failed, render login page with error message
            return render(
                request,
                "login-auth/login.html",
                {"error_message": "Invalid credentials"},
            )
    else:
        # Render the login page for GET requests
        return render(request, "login-auth/login.html")


def logout_view(request):
    if request.method == "POST":
        logout(request)
        return redirect("login")


@login_required
def dashboard_view(request):
    # This view is now secured and can only be accessed by logged-in users
    return render(request, "dashboard-sandbox/dashboard.html")


def splash_screen(request, participant_id):
    context = {"participant_id": participant_id}
    return render(request, "splash-screen/splash_screen.html", context)


def start_chatbot(request):
    if request.method != "POST":
        return HttpResponse("Only POST requests are allowed.", status=405)

    participant_id = request.POST.get("participant_id")
    chatbot_group = request.POST.get("chatbot_group")

    # Validate request data
    if not participant_id or not chatbot_group:
        return HttpResponseBadRequest("Missing participant ID or chatbot group.")

    if chatbot_group not in ["Group A - Helpful Chatbot", "Group B - Neutral Chatbot"]:
        return HttpResponseBadRequest("Invalid chatbot group specified.")

    try:
        chatbot_group_key = {
            "Group A - Helpful Chatbot": "Helpful",
            "Group B - Neutral Chatbot": "Neutral",
        }.get(chatbot_group, None)
        if not chatbot_group_key:
            return HttpResponseBadRequest("Invalid chatbot group specified.")

        participant, created = ParticipantConversation.objects.get_or_create(
            participant_id=participant_id,
            defaults={"chatbot_type": chatbot_group_key, "chatbot_conversation": []},
        )
        # To ensure that chatbot_conversation is updated regardless of get_or_create outcome
        if created or participant.chatbot_conversation is None:
            participant.chatbot_conversation = initial_messages
        else:
            participant.chatbot_conversation.extend(initial_messages)

        initial_messages = get_initial_messages(chatbot_group_key)
        print(initial_messages)

        if participant.chatbot_conversation is None:
            participant.chatbot_conversation = initial_messages
        else:
            participant.chatbot_conversation.extend(initial_messages)

        participant.chatbot_type = chatbot_group_key
        participant.save()

        welcome_message = initial_messages[0] if initial_messages else {}
        return JsonResponse(
            {
                "message": welcome_message.get("message", ""),
                "type": welcome_message.get("type", ""),
            }
        )
    except IntegrityError as e:
        # Handle unique constraint violations, etc.
        return HttpResponseBadRequest("Database integrity error: " + str(e))
    except ValidationError as e:
        # Handle validation errors from the model
        return HttpResponseBadRequest("Validation error: " + str(e))
    except Exception as e:
        # Catch-all for any other exceptions
        return HttpResponseBadRequest("An unexpected error occurred: " + str(e))

    return HttpResponse(
        f"Starting chatbot for Participant ID {participant_id} in Group {chatbot_group}"
    )
