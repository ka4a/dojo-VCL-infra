resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  chart      = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server"
  version    = var.metrics_server_config.chart_version
  namespace  = kubernetes_namespace.vcl_system.metadata.0.name

  values = [yamlencode(local.metrics_server_helm_values)]
}

locals {
  metrics_server_helm_values = {
    image = {
      repository = var.metrics_server_config.image_repo
      tag        = var.metrics_server_config.image_tag
    }

    replicas = var.metrics_server_config.deployment_replicas

    rbac = {
      create = var.metrics_server_config.rbac_create
    }

    "nodeSelector" = var.metrics_server_config.node_selector

    "args" = [
      "--kubelet-insecure-tls"
    ]
  }
}
