resource "kubernetes_priority_class" "ghost" {
  count = var.ghost_cpu_enabled ? 1 : 0

  metadata {
    name = "ghost"
  }

  description    = "Priority class used by ghost Pods."
  global_default = false
  value          = -1
}

resource "kubernetes_deployment" "ghost" {
  count = var.ghost_cpu_enabled ? 1 : 0

  metadata {
    name      = "ghost-cpu"
    namespace = kubernetes_namespace.vcl_core.metadata.0.name
  }

  spec {
    replicas = var.ghost_cpu_replicas

    selector {
      match_labels = {
        app = "ghost-cpu"
      }
    }

    template {

      metadata {
        labels = {
          app = "ghost-cpu"
        }
      }

      spec {
        node_selector = {
          "eks.amazonaws.com/nodegroup" = "cpu-workspaces"
        }
        priority_class_name = kubernetes_priority_class.ghost[0].metadata.0.name

        container {
          name  = "ghost-cpu"
          image = "k8s.gcr.io/pause"

          resources {
            limits = {
              cpu = var.ghost_cpu_resources
            }
          }
        }
      }
    }
  }
}


