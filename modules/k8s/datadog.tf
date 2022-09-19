resource "helm_release" "datadog" {
  count = var.datadog_enabled ? 1 : 0

  chart      = "datadog"
  name       = "datadog"
  repository = "https://helm.datadoghq.com"
  version    = var.datadog_chart_version
  namespace  = kubernetes_namespace.vcl_system.metadata.0.name

  values = [yamlencode(local.datadog_helm_values)]
}

locals {
  # https://github.com/DataDog/helm-charts/blob/main/charts/datadog/values.yaml
  datadog_helm_values = {
    registry = "public.ecr.aws/datadog"

    clusterAgent = {
      replicas     = var.datadog_cluster_agent_replicas
      nodeSelector = var.datadog_cluster_agent_node_selector
    }

    datadog = {
      apiKey      = var.datadog_api_key
      site        = "us3.datadoghq.com"
      clusterName = var.aws_eks_cluster_name

      containerInclude     = var.datadog_container_include
      containerIncludeLogs = var.datadog_container_include_logs
      containerExclude     = var.datadog_container_exclude
      containerExcludeLogs = var.datadog_container_exclude_logs


      apm = {
        portEnabled = "true"
      }

      confd = var.datadog_agent_confd

      dogstatsd = {
        useHostPort = "true"
      }

      logs = {
        enabled                = var.datadog_logs_enabled
        containerCollectAll    = "true"
        autoMultiLineDetection = "true"
      }

      networkMonitoring = {
        enabled = var.datadog_network_monitoring_enabled
      }

      processAgent = {
        processCollection     = var.datadog_process_agent_enabled
        stripProcessArguments = "true"
      }
    }

    targetSystem = "linux"
  }
}
