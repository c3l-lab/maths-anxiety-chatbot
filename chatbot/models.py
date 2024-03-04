from django.db import models
from django.contrib.auth.models import User
from django.core.exceptions import ValidationError
import json

# This model is used to store chatbot history for each participant.
class ParticipantConversation(models.Model):
    id = models.AutoField(primary_key=True)
    participant_id = models.CharField(max_length=100, unique=True)
    CHATBOT_CHOICES = [
        ("Helpful", "Group A - Helpful Chatbot"),
        ("Neutral", "Group B - Neutral Chatbot"),
    ]
    chatbot_type = models.CharField(max_length=50, choices=CHATBOT_CHOICES)
    chatbot_conversation = models.JSONField(blank=True, default = list)
    # Set to when the user starts their test
    chatbot_started_at = models.DateTimeField(null=True, blank=True)
    # Set to when the user finishes their test
    chatbot_finished_at = models.DateTimeField(null=True, blank=True)
    # These fields are standard row-level metadata fields
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.participant_id

    def clean(self):
        # Validate conversation JSON structure
        try:
            # Ensure conversation is a list
            if not isinstance(self.chatbot_conversation, list):
                raise ValidationError('Conversation must be a list.')
            for message in self.chatbot_conversation:
                # Check required keys in each message
                if 'type' not in message or 'message' not in message or 'timestamp' not in message:
                    raise ValidationError('Each message must include type, message, and timestamp keys.')
                # Validate 'type' to be either 'User' or 'Chatbot'
                if message['type'] not in ['User', 'Neutral Chatbot', 'Helpful Chatbot']:
                    raise ValidationError('Message type must be User, Neutral Chatbot, or Helpful Chatbot.')
        except TypeError:
            raise ValidationError('Invalid JSON format.')

    def save(self, *args, **kwargs):
        self.full_clean()  # Call the clean method to validate the JSON before saving
        super().save(*args, **kwargs)
