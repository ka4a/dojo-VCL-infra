resource "helm_release" "calico" {
  count = var.core_cluster ? 0 : 1

  name       = "calico"
  chart      = "tigera-operator"
  repository = "https://docs.projectcalico.org/charts/"
  namespace  = kubernetes_namespace.vcl_system.metadata.0.name

  max_history = 15
  atomic      = true
  wait        = true
  timeout     = 900

  depends_on = [var.eks_node_group_depends_on]
}

resource "null_resource" "workspaces_network_policy" {
  count = var.core_cluster ? 0 : 1

  triggers = {
    cluster_arn      = var.aws_eks_cluster_name
    cluster_endpoint = var.aws_eks_cluster_endpoint
    file_base64      = filebase64("${path.module}/files/workspaces-network-policy.yaml")
  }

  provisioner "local-exec" {
    working_dir = path.module

    environment = {
      KUBECONFIG = local.kubeconfig_filename
    }
    /*
    Installing calicoctl for managing Calico-specific resources
    calicoctl binary
    For MacOS:
    curl -L https://github.com/projectcalico/calico/releases/download/v3.22.1/calicoctl-darwin-amd64 -o calicoctl
    For Linux:
    curl -L https://github.com/projectcalico/calico/releases/download/v3.22.1/calicoctl-linux-amd64 -o calicoctl
    */
    command = <<-EOF
      curl -L https://github.com/projectcalico/calico/releases/download/${helm_release.calico[0].metadata[0].app_version}/calicoctl-linux-amd64 -o calicoctl
      chmod +x calicoctl
      ./calicoctl apply -f files/workspaces-network-policy.yaml
    EOF
  }

  depends_on = [
    null_resource.kubeconfig,
    helm_release.calico
  ]
}
