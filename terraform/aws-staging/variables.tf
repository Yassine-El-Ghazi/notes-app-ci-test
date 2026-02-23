variable "aws_region" {
  type        = string
  default     = "eu-west-1"
  description = "AWS region"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "EC2 instance type"
}

variable "docker_image" {
  type        = string
  description = "Docker image name (ex: username/notes-app)"
}

variable "docker_tag" {
  type        = string
  default     = "latest"
  description = "Docker image tag"
}

variable "registry_user" {
  type        = string
  description = "Docker Hub username"
  sensitive   = true
}

variable "registry_password" {
  type        = string
  description = "Docker Hub password or access token"
  sensitive   = true
}
