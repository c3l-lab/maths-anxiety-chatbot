from django.urls import path, reverse_lazy
from django.views.generic.base import RedirectView
from authentication.views import login_view, start_chatbot, dashboard_view, splash_screen
from chatbot.views import chat
from django.conf.urls.static import static, settings

urlpatterns = [
    # URL pattern for the chat interface
    path('chat/', chat, name='chat'),
    
    # URL pattern for the login page
    path('login/', login_view, name='login'),
    
    # Redirect requests to the root URL to the login page
    path('', RedirectView.as_view(url=reverse_lazy('login')), name='root'),

    # URL patter for the home page
    path('home/', dashboard_view, name='home'),

    # URL pattern for the start chatbot
    path('start-chatbot/', start_chatbot, name='start_chatbot'),

    # URL pattern for the splash screen with participant_id
    path('start/<str:participant_id>/', splash_screen, name='splash_screen'),

] + static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
