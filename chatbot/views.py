from django.shortcuts import render, redirect, get_object_or_404
from django.http import JsonResponse, HttpResponse
from .models import ParticipantConversation
from django import forms
from django.utils import timezone


# View for handling chatbot interactions
def chat(request):
    if request.method == 'POST':
        message_text = request.POST.get('message').strip().lower()  # Normalize the input
        participant_id = request.POST.get('participant_id')
        
        participant = get_object_or_404(ParticipantConversation, participant_id=participant_id)
        
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
            chatbot_response_text = "Understood. Feel free to ask me anything else or say 'end' to finish."
        else:
            # Fallback if the user's response doesn't match expected options
            chatbot_response_text = "I didn't catch that. Could you please respond with 'Yes' or 'No'?"
        
        chatbot_response = {
            "type": "Chatbot",
            "message": chatbot_response_text,
            "timestamp": timezone.now().isoformat(),
        }
        participant.chatbot_conversation.append(chatbot_response)
        
        participant.save()
        
        return JsonResponse({'message': chatbot_response_text})
    else:
        return HttpResponse('This endpoint supports only POST requests.')
