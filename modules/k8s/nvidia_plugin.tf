resource "helm_release" "nvidia_device_plugin" {
  count = var.gpu_nodes ? 1 : 0

  chart      = "nvidia-device-plugin"
  name       = "nvidia-device-plugin"
  repository = "https://nvidia.github.io/k8s-device-plugin"
  version    = var.nvidia_device_plugin_config.chart_version

  values = [yamlencode(local.nvidia_device_plugin_helm_values)]
}

locals {
  nvidia_device_plugin_helm_values = {
    nodeSelector = var.nvidia_device_plugin_config.node_selector
    namespace    = kubernetes_namespace.vcl_system.metadata.0.name

    image = {
      repository = var.nvidia_device_plugin_config.image_repo
      tag        = var.nvidia_device_plugin_config.image_tag
    }
  }
}
