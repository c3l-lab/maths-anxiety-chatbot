from django.db import models
from django.contrib.auth.models import User

# This model is used to store chatbot history for each participant.

class Participant(models.Model):
    user = models.OneToOneField(User, on_delete= models.CASCADE)
    # Any other participant-related fields can go here

class ChatMessage(models.Model):
    participant = models.ForeignKey(Participant, on_delete = models.CASCADE)
    message = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)