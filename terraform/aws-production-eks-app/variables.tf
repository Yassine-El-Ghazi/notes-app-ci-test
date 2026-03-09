variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "notes-app-production"
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "notes-app"
}

variable "docker_image" {
  description = "Docker image name"
  type        = string
}

variable "docker_tag" {
  description = "Docker image tag"
  type        = string
}
