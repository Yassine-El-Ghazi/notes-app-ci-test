terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  unique_suffix = random_id.suffix.hex
  key_name      = "notes-app-key-${local.unique_suffix}"
  sg_name       = "notes-app-staging-sg-${local.unique_suffix}"
  instance_name = "notes-app-staging-${local.unique_suffix}"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "tls_private_key" "staging" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_security_group" "staging_sg" {
  name        = local.sg_name
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

resource "aws_key_pair" "staging" {
  key_name   = local.key_name
  public_key = tls_private_key.staging.public_key_openssh
}

resource "aws_instance" "staging" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.staging_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.staging.key_name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              systemctl enable docker
              systemctl start docker
              usermod -aG docker ec2-user
              docker run -d --restart always -p 80:3000 \
                -e NODE_ENV=production \
                ${var.docker_image}:${var.docker_tag}
              EOF

  tags = {
    Name = local.instance_name
  }
}
