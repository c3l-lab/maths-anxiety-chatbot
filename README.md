# Maths Anxiety Chatbot (Chatty)

## Overview

This is a simple web based chatbot that was designed to be used for a research
study into mathematics anxiety.

## Contacts

- Tom Barone - Lead Developer, tbarone@comunet.com.au (Comunet)
- Leon Kimani - Developer, kimly013@mymail.unisa.edu.au (C3L)
- Dr Rebecca Marrone - Research Lead, Rebecca.Marrone@unisa.edu.au (C3L)

## Technical

This is a Ruby on Rails application that is deployed on a small `t2.micro` EC2
instance on AWS. Since it's such a simple application, we'll just use a local
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

### Development

Create a new `config/master.key` file so that the encrypted credentials can be
decrypted. The contents of this file are stored in AWS Secrets Manager in
`C3L-LIFT-PROD`.

Make sure the correct version of ruby is installed on your machine.

To setup a local development environment, run:

```bash
rails db:migrate
rails db:seed
rails server
```

For more information, see the [Rails Guides](https://guides.rubyonrails.org)

### EC2 Instance Setup

To setup a new EC2 instance to host the app, follow these steps in the AWS
console. The examples below are for the production instance.

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
9. Install [Homebrew](https://brew.sh/) so we can install Ruby
   - `export NONINTERACTIVE="true"`
   - `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
   - `(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/ubuntu/.bashrc`
   - `/home/linuxbrew/.linuxbrew/bin/brew install rbenv ruby-build openssl@3 readline libyaml zlib`
   - `echo 'eval "$(rbenv init - bash)"' >> /home/ubuntu/.bashrc`
   - `rbenv install 3.2.3`
   - `rbenv global 3.2.3`
   - `which ruby`
     - This should print out where the installed ruby is located
10. It's a good idea to install the latest updates on the EC2 instance.

- `sudo apt update`

11. Reboot the EC2 instance.
