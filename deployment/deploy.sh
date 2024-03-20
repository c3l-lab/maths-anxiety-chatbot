#!/bin/bash

####################################################################
#
# This script sets up an Ubuntu EC2 instance to serve the
# maths-anxiety-chatbot Django web application.
#
# Before starting, setup the following AWS resources:
#   1. Create a new EC2 instance
#   	- Name: maths-anxiety-chatbot
#   	- OS: Ubuntu Server 22.04 LTS
#   	- Architecture: x86
#   	- Instance Type: t2.micro
#   	- Key pair: (Create a new RSA .pem key pair) maths-anxiety-chatbot-key-pair
#   		- Save the .pem file to AWS Secrets Manager
#   	- VPC and Subnet: (pick the defaults)
#   	- Security Group: (Create a new security group) maths-anxiety-chatbot-security-group
#   		- Add rules for SSH, HTTP, and HTTPS access with source = 0.0.0.0/0
#   	- Storage: 20GB
#   2. Create a new Elastic IP
#   	- Name: maths-anxiety-chatbot-elastic-ip
#   3. Associate the Elastic IP with the EC2 instance
#   4. Create a new A record in the Route 52 DNS settings
#   	- The Route52 settings are in the C3L-MANAGEMENT AWS account
#   	- Record name: chatty.c3l.ai
#   	- Record type: A
#   	- Value: (the Elastic IP address)
#   5. SSH into the EC2 instance
#   	- `ssh -i "maths-anxiety-chatbot-key-pair.pem" ubuntu@chatty.c3l.ai`
#   6. Generate a new SSH key pair on the EC2 instance
#   	- `ssh-keygen -t ed25519 -C "chatty.c3l.ai"`
#   7. Create a deploy key in the project GitHub repository
#   	- Name: chatty.c3l.ai
#   	- Public key: (the contents of the .pub file created by `ssh-keygen`)
#   8. Clone the project repository to the EC2 instance
#   	- `eval "$(ssh-agent -s)"`
#   	- `ssh-add ~/.ssh/id_ed25519`
#   	- `git clone git@github.com:c3l-lab/maths-anxiety-chatbot.git`
#
# Now we can setup a Github Actions workflow to SSH into the EC2
# instance and run this script to deploy the Django web application.
#
####################################################################

set -e # Exit on error

if [ "$(pwd)" != "/home/ubuntu/maths-anxiety-chatbot" ]; then
	echo "This script should be run from the maths-anxiety-chatbot git repository."
	exit 1
fi

# Check that the environment variables are set
if [ "$SECRET_KEY" == "" ]; then
	echo "The SECRET_KEY environment variable is not set."
	exit 1
fi
if [ "$DOMAIN" == "" ]; then
	echo "The DOMAIN environment variable is not set."
	exit 1
fi

# Set the secret key
echo "$SECRET_KEY" >./secret_key.txt

sudo apt update
sudo apt install pipx nginx python3.11 -y

# Install pipx and poetry
pipx ensurepath
# shellcheck source=/dev/null
. "$HOME/.bashrc" # Load the new PATH
pipx install poetry
poetry install

# Install certbot and get some LetsEncrypt certificates
sudo snap install core && sudo snap refresh core
sudo snap install --classic certbot
if [ ! -f /usr/bin/certbot ]; then
	sudo ln -s /snap/bin/certbot /usr/bin/certbot
fi
sudo certbot certonly --nginx -m tbarone@comunet.com.au --agree-tos --non-interactive --domains "${DOMAIN}"
# Certificate is saved at: /etc/letsencrypt/live/${DOMAIN}/fullchain.pem
# Key is saved at:         /etc/letsencrypt/live/${DOMAIN}/privkey.pem

# Setup Nginx and Supervisor
# Using instructions from https://channels.readthedocs.io/en/latest/deploying.html
sudo tee /etc/nginx/sites-available/maths-anxiety-chatbot <<EOF
upstream channels-backend {
		server localhost:8000;
}
server {
    listen 80;
    location / {  
        proxy_pass http://127.0.0.1:8000/; 
				proxy_redirect off;
				proxy_http_version 1.1;
				proxy_set_header Upgrade \$http_upgrade;
				proxy_set_header Connection "upgrade";
				proxy_set_header Host \$host;
    }
		location = /favicon.ico { access_log off; log_not_found off; }
		location /static/ {
				root /home/ubuntu/maths-anxiety-chatbot/static/;
		}
}
server {
    listen 443 ssl;
		ssl_certificate /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;
		ssl_certificate_key /etc/letsencrypt/live/${DOMAIN}/privkey.pem;
    location / { 
        proxy_pass http://127.0.0.1:8000/;
				proxy_redirect off;
				proxy_http_version 1.1;
				proxy_set_header Upgrade \$http_upgrade;
				proxy_set_header Connection "upgrade";
				proxy_set_header Host \$host;
    }
		location = /favicon.ico { access_log off; log_not_found off; }
		location /static/ {
				root /home/ubuntu/maths-anxiety-chatbot;
		}
}
EOF
sudo sed -i "/user www-data;/c\user ubuntu;" /etc/nginx/nginx.conf # Change the user to ubuntu
sudo rm -f /etc/nginx/sites-enabled/default
sudo rm -f /etc/nginx/sites-enabled/maths-anxiety-chatbot
sudo ln -s /etc/nginx/sites-available/maths-anxiety-chatbot /etc/nginx/sites-enabled/
sudo systemctl restart nginx

# Setup the Django static files
sudo rm -rf ./static
poetry run python manage.py collectstatic --noinput

# Setup the systemd service
sudo tee /etc/systemd/system/maths-anxiety-chatbot.service <<EOF
# This is a systemd service to manage and auto start the Django app

[Unit]
Description=Maths Anxiety Chatbot Django App
# Make sure there's no restart limit
# https://medium.com/@benmorel/creating-a-linux-service-with-systemd-611b5c8b91d6
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=60
User=ubuntu
Group=ubuntu
Environment="DJANGO_LOG_LEVEL=debug"
Environment="DJANGO_SETTINGS_MODULE=anxiety_chatbot_project.settings-production"
WorkingDirectory=/home/ubuntu/maths-anxiety-chatbot
ExecStart=/home/ubuntu/.local/bin/poetry run daphne anxiety_chatbot_project.asgi:application

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable maths-anxiety-chatbot # Enable the service to start on boot
sudo systemctl restart maths-anxiety-chatbot
