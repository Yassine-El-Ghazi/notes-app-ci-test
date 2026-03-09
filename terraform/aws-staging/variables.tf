variable "aws_region" {
  description = "AWS region for staging"
  type        = string
  default     = "eu-west-1"
}

variable "instance_type" {
  description = "EC2 instance type for staging"
  type        = string
  default     = "t3.micro"
}

variable "docker_image" {
  description = "Docker image name"
  type        = string
}

variable "docker_tag" {
  description = "Docker image tag"
  type        = string
}

variable "registry_user" {
  description = "Docker registry username"
  type        = string
  sensitive   = true
}

variable "registry_password" {
  description = "Docker registry password"
  type        = string
  sensitive   = true
}
