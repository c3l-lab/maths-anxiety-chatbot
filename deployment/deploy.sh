#!/bin/bash

####################################################################
#
# This script deploys the maths-anxiety-chatbot app to an EC2 instance.
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
	RAILS_MASTER_KEY \
	DOMAIN \
	DEPLOY_BRANCH; do
	if [ -z "${!var}" ]; then
		echo "Error: The $var environment variable is not set."
		echo ""
		echo "The following environment variables must be set:"
		echo "  SSH_KEY_FILE: The path to the SSH key .pem file that has access to the server, these .pem files can be found in AWS Secrets Manager"
		echo "  RAILS_MASTER_KEY: The Rails master key to use for decryption"
		echo "  DOMAIN: The domain name of the server (chatty.c3l.ai)"
		echo "  DEPLOY_BRANCH: The branch to deploy (main)"
		exit 1
	fi
done

# Create a temporary script that we'll then run on the web server
tee tmp.sh <<EOF_SERVER
cd ~/maths-anxiety-chatbot
git fetch
git pull origin "${DEPLOY_BRANCH}"

# Set the secret key
echo "${RAILS_MASTER_KEY}" > config/master.key

# Update things
sudo apt update

# Install ruby 3.2.3
/home/linuxbrew/.linuxbrew/bin/brew install ruby@3.2

# Setup the rails app
/home/linuxbrew/.linuxbrew/opt/ruby@3.2/bin/bundle config set --local deployment 'true'
/home/linuxbrew/.linuxbrew/opt/ruby@3.2/bin/bundle config set --local without 'development test'
/home/linuxbrew/.linuxbrew/opt/ruby@3.2/bin/bundle install
/home/linuxbrew/.linuxbrew/opt/ruby@3.2/bin/bundle exec rake assets:precompile db:migrate db:seed RAILS_ENV=production
# Add the default user
/home/linuxbrew/.linuxbrew/opt/ruby@3.2/bin/bundle exec rake db:seed

# Install Passenger
# https://www.phusionpassenger.com/docs/advanced_guides/install_and_upgrade/standalone/install/oss/jammy.html
sudo apt-get install -y dirmngr gnupg apt-transport-https ca-certificates curl
curl https://oss-binaries.phusionpassenger.com/auto-software-signing-gpg-key.txt | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/phusion.gpg >/dev/null
sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger jammy main > /etc/apt/sources.list.d/passenger.list'
sudo apt-get update
sudo apt-get install -y passenger libnginx-mod-http-passenger
sudo /usr/bin/passenger-config validate-install --auto

# Install and setup Nginx
sudo apt install nginx -y

# Install certbot and get some LetsEncrypt certificates
sudo snap install core && sudo snap refresh core
sudo snap install --classic certbot
if [ ! -f /usr/bin/certbot ]; then
	sudo ln -s /snap/bin/certbot /usr/bin/certbot
fi
sudo certbot certonly --nginx -m tbarone@comunet.com.au --agree-tos --non-interactive --domains "${DOMAIN}"
# Certificate is saved at: /etc/letsencrypt/live/${DOMAIN}/fullchain.pem
# Key is saved at:         /etc/letsencrypt/live/${DOMAIN}/privkey.pem

sudo tee /etc/nginx/sites-available/maths-anxiety-chatbot <<EOF
server {
    listen 80;
    server_name ${DOMAIN};

    # Tell Nginx and Passenger where your app's 'public' directory is
    root /home/ubuntu/maths-anxiety-chatbot/public;

    # Turn on Passenger
    passenger_enabled on;
    passenger_ruby /home/linuxbrew/.linuxbrew/opt/ruby@3.2/bin/ruby;
}
server {
    listen 443 ssl;
    server_name ${DOMAIN};
		ssl_certificate /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;
		ssl_certificate_key /etc/letsencrypt/live/${DOMAIN}/privkey.pem;

    # Tell Nginx and Passenger where your app's 'public' directory is
    root /home/ubuntu/maths-anxiety-chatbot/public;

    # Turn on Passenger
    passenger_enabled on;
    passenger_ruby /home/linuxbrew/.linuxbrew/opt/ruby@3.2/bin/ruby;
}
EOF
sudo sed -i "/user www-data;/c\\user ubuntu;" /etc/nginx/nginx.conf # Change the user to ubuntu
sudo rm -f /etc/nginx/sites-enabled/default
sudo rm -f /etc/nginx/sites-enabled/maths-anxiety-chatbot
sudo ln -s /etc/nginx/sites-available/maths-anxiety-chatbot /etc/nginx/sites-enabled/
sudo service nginx restart

echo 'Deployment successfully completed.'

EOF_SERVER

# Run the script on the server (don't worry about host key checking)
ssh -o StrictHostKeyChecking=no -i "$SSH_KEY_FILE" ubuntu@"$DOMAIN" <tmp.sh

rm tmp.sh
