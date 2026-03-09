terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = "notes-app"
    namespace = var.namespace
    labels = {
      app = "notes-app"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "notes-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "notes-app"
        }
      }

      spec {
        container {
          name  = "notes-app"
          image = "${var.docker_image}:${var.docker_tag}"

          port {
            container_port = 3000
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 3000
            }
            initial_delay_seconds = 5
            period_seconds        = 5
            timeout_seconds       = 1
            failure_threshold     = 3
            success_threshold     = 1
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 3000
            }
            initial_delay_seconds = 15
            period_seconds        = 10
            timeout_seconds       = 1
            failure_threshold     = 3
            success_threshold     = 1
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name      = "notes-app-service"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "notes-app"
    }

    port {
      port        = 80
      target_port = 3000
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }
}

output "namespace" {
  value = var.namespace
}

output "service_name" {
  value = kubernetes_service.app.metadata[0].name
}
