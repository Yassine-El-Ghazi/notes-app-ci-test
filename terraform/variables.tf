variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "cluster_name" {
  type    = string
  default = "notes-app-production"
}

variable "app_name" {
  type    = string
  default = "notes-app"
}

variable "docker_image" {
  type = string
}

variable "docker_tag" {
  type    = string
  default = "latest"
}
