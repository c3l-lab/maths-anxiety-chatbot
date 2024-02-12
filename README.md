# Overview
This project aims to develop an anxiety chatbot to provide support and guidance for individuals experiencing stress and anxiety during math tests. The chatbot utilizes visualization techniques and guided imagery to help users manage their anxiety and improve their confidence.

# Features
User Authentication: Participants can log in using their credentials to access the chatbot.
Chat Interface: Interactive chat interface for users to communicate with the chatbot.
Guided Imagery: The chatbot provides step-by-step visualization techniques to help users reduce anxiety.
Chat History: Logging and storage of chat history for each participant.
Data Export: Ability to download all chatbot interactions and participant data for research purposes.
# Technologies Used
* Python: Backend development using Django framework.
* Django: Web framework for building the chatbot application.
* HTML/CSS/JavaScript: Frontend development for the chat interface.
* PostgreSQL: Database management system for storing participant data and chat history.
* AWS: Cloud platform for deployment and hosting of the application.
* Qualtrics: Integration with Qualtrics for participant management and test administration.
# Project Structure
* anxiety_chatbot_project/: Django project directory.
  * chatbot/: Django app directory for the chatbot.
    * models.py: Defines database models for storing participant data and chat history.
    * views.py: Implements views for handling chatbot interactions.
    * templates/: HTML templates for the chat interface.
    * static/: Static files (CSS, JavaScript) for frontend development.
* anxiety_chatbot_project/: Main project directory containing settings and configurations.
* manage.py: Django management script for running commands.

# Setup Instructions

* Clone the repository: git clone https://github.com/yourusername/anxiety-chatbot.git
* Install dependencies: pip install -r requirements.txt
* Configure Django settings: Update settings.py with database settings, secret key, etc.
* Run migrations: python manage.py migrate
* Create a superuser: python manage.py createsuperuser
* Start the development server: python manage.py runserver

# Usage

* Access the chatbot interface at http://localhost:8000/chat/ (or the appropriate URL).
* Log in using your credentials.
* Interact with the chatbot by typing messages in the chat interface.
* Visualize success and follow the chatbot's guidance for anxiety reduction during math tests.
