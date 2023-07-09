#!/bin/bash
# Install Docker
yum update
yum install -y docker
systemctl start docker
systemctl enable docker
gpasswd -a ec2-user docker

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
