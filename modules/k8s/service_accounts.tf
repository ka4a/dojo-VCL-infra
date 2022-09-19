# Service account for VCL Backend
resource "kubernetes_service_account" "vcl_web" {
  count = var.core_cluster ? 1 : 0

  metadata {
    name      = "vcl-core"
    namespace = kubernetes_namespace.vcl_core.metadata.0.name

    annotations = {
      "eks.amazonaws.com/role-arn" = var.vcl_web_sa_iam_role_arn
    }
  }
}

# Service account for ws-supervisor
resource "kubernetes_service_account" "vcl_ws_supervisor" {
  count = var.core_cluster ? 0 : 1

  metadata {
    name      = "vcl-ws-supervisor"
    namespace = kubernetes_namespace.vcl_core.metadata.0.name
  }
}

# ClusterRoleBinding for ws-supervisor
resource "kubernetes_cluster_role_binding" "vcl_ws_supervisor" {
  count = var.core_cluster ? 0 : 1

  metadata {
    name = "vcl-ws-supervisor"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.vcl_ws_supervisor[0].metadata.0.name
    namespace = kubernetes_service_account.vcl_ws_supervisor[0].metadata.0.namespace
  }
}
