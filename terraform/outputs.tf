output "cluster_name" {
  value = module.eks.cluster_name
}

output "service_name" {
  value = kubernetes_service.app.metadata[0].name
}

output "namespace" {
  value = kubernetes_namespace.app.metadata[0].name
}
