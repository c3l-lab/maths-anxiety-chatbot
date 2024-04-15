# Deployment

This rails application is deployed on a small `t2.micro` EC2 instance on AWS.
Since it's such a simple application, we'll just use a local
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
9. Install [Homebrew](https://brew.sh/) so we can install Ruby
   - `export NON_INTERACTIVE="true"`
   - `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
   - `(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/ubuntu/.bashrc`
10. It's a good idea to install the latest updates on the EC2 instance.
   - `sudo apt update`
   - `sudo apt upgrade -y`
11. Reboot the EC2 instance.
