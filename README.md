# Overview

This project aims to develop an anxiety chatbot to provide support and guidance
for individuals experiencing stress and anxiety during math tests. The chatbot
utilizes visualization techniques and guided imagery to help users manage their
anxiety and improve their confidence.

# Features

User Authentication: Participants can log in using their credentials to access
the chatbot. Chat Interface: Interactive chat interface for users to communicate
with the chatbot. Guided Imagery: The chatbot provides step-by-step
visualization techniques to help users reduce anxiety. Chat History: Logging and
storage of chat history for each participant. Data Export: Ability to download
all chatbot interactions and participant data for research purposes.

# Technologies Used

- Python: Backend development using Django framework.
- Django: Web framework for building the chatbot application.
- HTML/CSS/JavaScript: Frontend development for the chat interface.
- PostgreSQL: Database management system for storing participant data and chat
  history.
- AWS: Cloud platform for deployment and hosting of the application.
- Qualtrics: Integration with Qualtrics for participant management and test
  administration.

# Project Structure

- anxiety_chatbot_project/: Django project directory.
  - chatbot/: Django app directory for the chatbot.
    - models.py: Defines database models for storing participant data and chat
      history.
    - views.py: Implements views for handling chatbot interactions.
    - templates/: HTML templates for the chat interface.
    - static/: Static files (CSS, JavaScript) for frontend development.
- anxiety_chatbot_project/: Main project directory containing settings and
  configurations.
- manage.py: Django management script for running commands.

# Setup Instructions

- Clone the repository: git clone
  https://github.com/yourusername/anxiety-chatbot.git
- Install dependencies: pip install -r requirements.txt
- Configure Django settings: Update settings.py with database settings, secret
  key, etc.
- Run migrations: python manage.py migrate
- Create a superuser: python manage.py createsuperuser
- Start the development server: python manage.py runserver

# Usage

- Access the chatbot interface at http://localhost:8000/chat/ (or the
  appropriate URL).
- Log in using your credentials.
- Interact with the chatbot by typing messages in the chat interface.
- Visualize success and follow the chatbot's guidance for anxiety reduction
  during math tests.

# Deployment

The application is deployed on a small `t2.micro` EC2 instance on AWS. Since
it's such a simple application, we'll just use a local
[`sqlite3`](https://www.sqlite.org/) database on the instance for storage.

We have 2 EC2 instances:

1. Production
   - Website: https://chatty.c3l.ai
   - Deployed on every push to the `main` branch using GitHub Actions
   - Deployed to the `C3L-LIFT-PROD` account
2. UAT (User Acceptance Testing)
   - Website: https://chatty-uat.c3l.ai
   - Deployed on every push to the `dev` branch using GitHub Actions
   - Deployed to the `C3L-LIFT-DEV` account

### EC2 Instance Setup

To setup an EC2 instance, follow these steps in the AWS console. The examples
below are for the production instance.

1. Create a new EC2 instance:
   - Name: `maths-anxiety-chatbot-prod`
   - OS: `Ubuntu Server 22.04 LTS`
   - Architecture: `x86`
   - Instance Type: `t2.micro`
   - Key pair: (Create a new RSA .pem key pair)
     `maths-anxiety-chatbot-prod-key-pair`
     - Save the .pem file to AWS Secrets Manager
   - VPC and Subnet: (Pick the defaults)
   - Security Group: (Create a new security group)
     `maths-anxiety-chatbot-prod-security-group`
     - Add rules for SSH, HTTP, and HTTPS access with source = `0.0.0.0/0`
   - Storage: `20GB`
2. Create a new Elastic IP:
   - Name: `maths-anxiety-chatbot-prod-elastic-ip`
3. Associate the Elastic IP with the EC2 instance
4. Create a new A record in the Route 52 DNS settings
   - The Route52 settings are in the `C3L-MANAGEMENT` AWS account
   - Record name: `chatty.c3l.ai`
   - Record type: A
   - Value: (the Elastic IP address)
5. SSH into the EC2 instance
   - `ssh -i "maths-anxiety-chatbot-prod-key-pair.pem" ubuntu@chatty.c3l.ai`
6. Generate a new SSH key pair on the EC2 instance
   - `ssh-keygen -t ed25519 -C "chatty.c3l.ai"`
7. Create a deploy key in the project GitHub repository
   - Name: `chatty.c3l.ai`
   - Public key: (the contents of the .pub file created by `ssh-keygen`)
8. Clone the project repository to the EC2 instance
   - `eval "$(ssh-agent -s)"`
   - `ssh-add ~/.ssh/id_ed25519`
   - `git clone git@github.com:c3l-lab/maths-anxiety-chatbot.git`
