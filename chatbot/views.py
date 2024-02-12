from django.shortcuts import render
from django.http import JsonResponse
from .models import Participant, ChatMessage

# This view is used to handle chatbot interactions
def chat(request):
    if request.method == 'POST':
        message_text = request.POST.get('message')
        participant_id = request.POST.get('participant_id')  # Assuming participant ID is passed in the request
        participant = Participant.objects.get(id=participant_id)
        # Perform chatbot logic here (NLP processing, response generation, etc.)
        # Save chat history
        ChatMessage.objects.create(participant=participant, message=message_text)
        # Dummy response for now
        response_data = {'message': 'This is a dummy response from the chatbot.'}
        return JsonResponse(response_data)
    return render(request, 'chatbot/chat.html')  # We will probably replace 'chat.html' with your chat interface template