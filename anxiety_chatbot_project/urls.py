from django.contrib import admin
from django.urls import path
from chatbot.views import chat

urlpatterns = [
    path('chat/', chat, name='chat'),  # URL pattern for the chat interface
    path('', chat, name='default_chat'),  # Default URL pattern to redirect requests to the chat interface
]
