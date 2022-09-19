resource "helm_release" "traefik" {
  count = var.core_cluster ? 0 : 1

  name        = "traefik"
  chart       = "traefik"
  repository  = "https://helm.traefik.io/traefik"
  version     = var.traefik_config.chart_version
  namespace   = kubernetes_namespace.vcl_system.metadata.0.name
  max_history = 15
  atomic      = true
  wait        = true
  timeout     = 600

  values = [yamlencode(local.traefik_helm_values)]
}

locals {
  traefik_iam_resources_name = "eks-${var.aws_eks_cluster_name}-traefik"

  traefik_helm_values = {
    replicaCount      = var.traefik_config.deployment_replicas
    nodeSelector      = var.traefik_config.node_selector
    priorityClassName = "system-cluster-critical"
    resources         = var.traefik_config.resources

    deployment = {
      labels = var.datadog_enabled ? {
        "admission.datadoghq.com/enabled" = "true"
      } : {}

      podLabels = var.datadog_enabled ? {
        "admission.datadoghq.com/enabled" = "true"
      } : {}
    }

    metrics = var.datadog_enabled ? {
      datadog = {
        address = "$(DD_AGENT_HOST):8125"
      }
    } : {}

    tracing = var.datadog_enabled ? {
      datadog = {
        localAgentHostPort = "$(DD_AGENT_HOST):8126"
      }
    } : {}

    rollingUpdate = {
      maxUnavailable = "50%"
      maxSurge       = "50%"
    }

    providers = {
      kubernetesIngress = {
        enabled = false
      }
    }

    logs = {
      general = {
        level = "INFO"
      }
    }

    service = {
      enabled = true
      type    = "ClusterIP"
    }
  }
}
