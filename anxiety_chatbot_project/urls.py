from django.conf.urls.static import settings, static
from django.contrib import admin
from django.urls import path, reverse_lazy
from django.views.generic.base import RedirectView

from chatbot.views import (chat, dashboard_view, login_view, logout_view,
                           splash_screen, start_chatbot)

urlpatterns = [
    # URL pattern for the chat interface
    path("chat/", chat, name="chat"),
    # URL pattern for the login and logout
    path("login/", login_view, name="login"),
    path("logout/", logout_view, name="logout"),
    # Redirect requests to the root URL to the login page
    path("", RedirectView.as_view(url=reverse_lazy("login")), name="root"),
    # URL patter for the home page
    path("home/", dashboard_view, name="home"),
    # URL pattern for the start chatbot
    path("start-chatbot/", start_chatbot, name="start_chatbot"),
    # URL pattern for the splash screen with participant_id
    path("start/<str:participant_id>/", splash_screen, name="splash_screen"),
    # URL pattern for the admin page
    path("admin/", admin.site.urls),
] + static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
