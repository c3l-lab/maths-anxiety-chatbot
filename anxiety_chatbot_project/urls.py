from django.contrib import admin
from django.urls import path
from chatbot.views import chat
from authentication.views import login_view

urlpatterns = [
    path('chat/', chat, name='chat'),  # URL pattern for the chat interface
     path('login/', login_view, name='login'), # URL pattern for the login page
    path('', chat, name='default_chat'),  # Default URL pattern to redirect requests to the chat interface
]
