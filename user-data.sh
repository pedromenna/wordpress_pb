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

# Configuração EFS
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
sudo yum install git
sudo mkdir -p /mnt/efs/wordpress
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-069b6cb64a852692f.efs.us-east-1.amazonaws.com:/ /mnt/efs

# Configuração banco de dados
export WORDPRESS_DB_HOST="database-pb2.cpy1vk3kgfvg.us-east-1.rds.amazonaws.com"
export WORDPRESS_DB_USER="adminpb"
export WORDPRESS_DB_PASSWORD="teste123" 
export WORDPRESS_DB_NAME="database-pb2"

# Execução do container
sudo cd /home/ec2-user
sudo git clone https://github.com/pedromenna/wordpress_pb.git
sudo cd wordpress_pb
sudo docker compose up -d
