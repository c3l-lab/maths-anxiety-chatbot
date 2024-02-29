from django.shortcuts import render, redirect, get_object_or_404
from django.http import JsonResponse, HttpResponse
from .models import ParticipantConversation
from django import forms
from django.utils import timezone


# View for handling chatbot interactions
def chat(request):
    if request.method == 'POST':
        message_text = request.POST.get('message')
        participant_id = request.POST.get('participant_id')
        
        # Retrieve the participant's conversation object
        participant = get_object_or_404(ParticipantConversation, participant_id=participant_id)
        
        # Assuming you're handling a user message here
        user_message = {
            "type": "User",
            "message": message_text,
            "timestamp": timezone.now().isoformat(),
        }
        
        # Append the user message to the conversation
        if not participant.chatbot_conversation:
            participant.chatbot_conversation = [user_message]
        else:
            participant.chatbot_conversation.append(user_message)
        
        # Here, you would also handle generating and appending the chatbot's response in a similar manner
        
        participant.save()  # Save the updated conversation
        
        # Dummy response for now
        response_data = {'message': 'This is a dummy response from the chatbot.'}
        return JsonResponse(response_data)
    else:
        return render(request, 'chatbot-interface/chat.html')

# View for displaying the homepage/dashboard
def homepage(request):
    participants = ParticipantConversation.objects.all()
    return render(request, 'dashboard.html', {'participants': participants})