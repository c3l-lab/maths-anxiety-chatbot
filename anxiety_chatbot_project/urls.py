from django.urls import path, reverse_lazy
from django.views.generic.base import RedirectView
from authentication.views import login_view
from chatbot.views import chat

urlpatterns = [
    # URL pattern for the chat interface
    path('chat/', chat, name='chat'),
    
    # URL pattern for the login page
    path('login/', login_view, name='login'),
    
    # Redirect requests to the root URL to the login page
    path('', RedirectView.as_view(url=reverse_lazy('login')), name='root'),
]
