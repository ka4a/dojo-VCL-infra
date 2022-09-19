output "core_namespace" {
  value = var.core_cluster ? kubernetes_namespace.vcl_core.metadata.0.name : null
}
