from django.utils import timezone


def get_initial_messages(chatbot_group):
    if chatbot_group == 'Group A - Helpful Chatbot':
        return [
            {
                "type": "Group A - Helpful Chatbot",
                "message": "Hello! I'm Chatty the Chatbot. I'm here to assist you through your test. Don't worry, take a deep breath, and let's tackle this together.",
                "timestamp": timezone.now().isoformat(),
            }
        ]
    elif chatbot_group == 'Group B - Neutral Chatbot':
        return [
            {
                "type": "Group B - Neutral Chatbot",
                "message": "Hi there, I'm Chatty the Chatbot. I’ll be here to keep you company throughout your test and provide some extra support.",
                "timestamp": timezone.now().isoformat(),
            }
        ]
    else:
        # Default message or an error message if the group is unrecognized
        return []
