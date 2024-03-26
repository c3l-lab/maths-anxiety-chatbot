#!/bin/bash

####################################################################
#
# This script deploys the maths-anxiety-chatbot django app to an EC2
# instance.
#
####################################################################

set -e # Exit on error

# If a .env file exists, load it
if [ -f .env ]; then
	# shellcheck source=/dev/null
	source .env
fi

# Check that all our environment variables are set
for var in SSH_KEY_FILE \
	DOMAIN \
	DJANGO_SUPERUSER_USERNAME \
	DJANGO_SUPERUSER_EMAIL \
	DJANGO_SUPERUSER_PASSWORD \
	DJANGO_SECRET_KEY \
	DEPLOY_BRANCH \
	DJANGO_SETTINGS_MODULE; do
	if [ -z "${!var}" ]; then
		echo "Error: The $var environment variable is not set."
		echo ""
		echo "The following environment variables must be set:"
		echo "  SSH_KEY_FILE: The path to the SSH key .pem file that has access to the server, these .pem files can be found in AWS Secrets Manager"
		echo "  DOMAIN: The domain name of the server (chatty.c3l.ai)"
		echo "  DJANGO_SUPERUSER_USERNAME: The username of the superuser (lab.manager)"
		echo "  DJANGO_SUPERUSER_EMAIL: The email of the superuser (lab.manager@c3l.ai)"
		echo "  DJANGO_SUPERUSER_PASSWORD: The password of the superuser"
		echo "  DJANGO_SECRET_KEY: The secret key used by Django for crypto hashing and signing"
		echo "  DEPLOY_BRANCH: The branch to deploy (main)"
		echo "  DJANGO_SETTINGS_MODULE: The Django settings module to use (anxiety_chatbot_project.settings-production)"
		exit 1
	fi
done

# Create a temporary script that we'll then run on the web server
tee tmp.sh <<EOF_SERVER
cd ~/maths-anxiety-chatbot
git fetch
git pull origin "$DEPLOY_BRANCH"

# Set the secret key and environment variables
echo "$DJANGO_SECRET_KEY" >./secret_key.txt
export DJANGO_SUPERUSER_USERNAME="$DJANGO_SUPERUSER_USERNAME"
export DJANGO_SUPERUSER_EMAIL="$DJANGO_SUPERUSER_EMAIL"
export DJANGO_SUPERUSER_PASSWORD="$DJANGO_SUPERUSER_PASSWORD"
export DJANGO_SETTINGS_MODULE="$DJANGO_SETTINGS_MODULE"

# Setup ubuntu packages
sudo apt update
sudo apt install pipx nginx python3.11 -y

# Install pipx and poetry
pipx install poetry
pipx ensurepath
. "/home/ubuntu/.bashrc" # Load the new PATH
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
				proxy_set_header Upgrade \\\$http_upgrade;
				proxy_set_header Connection "upgrade";
				proxy_set_header Host \\\$host;
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
				proxy_set_header Upgrade \\\$http_upgrade;
				proxy_set_header Connection "upgrade";
				proxy_set_header Host \\\$host;
    }
		location = /favicon.ico { access_log off; log_not_found off; }
		location /static/ {
				root /home/ubuntu/maths-anxiety-chatbot;
		}
}
EOF
sudo sed -i "/user www-data;/c\\user ubuntu;" /etc/nginx/nginx.conf # Change the user to ubuntu
sudo rm -f /etc/nginx/sites-enabled/default
sudo rm -f /etc/nginx/sites-enabled/maths-anxiety-chatbot
sudo ln -s /etc/nginx/sites-available/maths-anxiety-chatbot /etc/nginx/sites-enabled/
sudo systemctl restart nginx

# Setup the Django static files
sudo rm -rf ./static
poetry run python manage.py collectstatic --noinput

# Run the Django migrations
poetry run python manage.py migrate

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

# Create the superuser
poetry run python manage.py createsuperuser --no-input || true

echo 'Deployment successfully completed.'

EOF_SERVER

# Run the script on the server (don't worry about host key checking)
ssh -o StrictHostKeyChecking=no -i "$SSH_KEY_FILE" ubuntu@"$DOMAIN" <tmp.sh

rm tmp.sh
