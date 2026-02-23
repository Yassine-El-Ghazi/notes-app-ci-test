terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

############################
# Default VPC & Subnet
############################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

############################
# Security Group
############################
resource "aws_security_group" "staging_sg" {
  name        = "notes-app-staging-sg"
  description = "Allow HTTP (80) and SSH (22)"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################
# SSH Key (auto generated)
############################
resource "tls_private_key" "staging" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "staging" {
  key_name   = "notes-app-key"
  public_key = tls_private_key.staging.public_key_openssh
}

############################
# Amazon Linux 2 AMI
############################
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

############################
# EC2 Instance
############################
resource "aws_instance" "staging" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.staging.key_name
  vpc_security_group_ids      = [aws_security_group.staging_sg.id]
  subnet_id                   = tolist(data.aws_subnets.default.ids)[0]
  associate_public_ip_address = true

  user_data = <<-EOT
#!/bin/bash
set -e

# Update system
yum update -y

# Install Docker
yum install -y docker
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group
usermod -aG docker ec2-user

# Login to Docker Hub
echo "${var.registry_password}" | docker login -u "${var.registry_user}" --password-stdin

# Pull image
docker pull ${var.docker_image}:${var.docker_tag}

# Stop old container if exists
docker stop notes-app || true
docker rm notes-app || true

# Run container
docker run -d \
  --name notes-app \
  --restart unless-stopped \
  -p 80:3000 \
  ${var.docker_image}:${var.docker_tag}

EOT

  tags = {
    Name = "notes-app-staging"
  }
}
