#!/bin/bash

# Update and upgrade sources and packages
sudo apt-get -y update
sudo apt-get -y upgrade

# Remove older versions of docker, if any
sudo apt-get -y remove docker docker-engine docker.io containerd runc

# Get some dependencies

sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add docker's repo to apt sources
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Update sources
sudo apt-get -y update

# Install docker
sudo apt-get -y install docker-ce docker-ce-cli containerd.io

# Get docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Add execute perms and group perms
sudo chmod +x /usr/local/bin/docker-compose

# Get our prod docker-compose file
curl https://raw.githubusercontent.com/mvkaran/django-dashboard-adminator/master/docker-compose.prod.yml -o docker-compose.prod.yml

# Create ENV file
touch .env

cat <<EOT >> .env
DEBUG=False
SECRET_KEY=S3cr3t_K#Key
EOT

TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` 

SERVER="SERVER="
IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)

echo $SERVER$IP >> .env

# Bring up the containers
sudo docker-compose -f docker-compose.prod.yml up -d

# Send notification
curl -d 'name=karan' https://hooks.zapier.com/hooks/catch/8117939/okhctfz/