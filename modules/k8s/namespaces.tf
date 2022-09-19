resource "kubernetes_namespace" "vcl_system" {
  metadata {
    name = var.system_namespace
  }
}

resource "kubernetes_namespace" "vcl_core" {
  metadata {
    name = "vcl-core"

    labels = var.core_cluster ? { "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled" } : {}
  }
}
