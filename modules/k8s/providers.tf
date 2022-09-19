provider "kubernetes" {
  host                   = var.aws_eks_cluster_endpoint
  cluster_ca_certificate = base64decode(var.aws_eks_cluster_certificate_authority_data_base64)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.aws_eks_cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = var.aws_eks_cluster_endpoint
    cluster_ca_certificate = base64decode(var.aws_eks_cluster_certificate_authority_data_base64)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", var.aws_eks_cluster_name]
      command     = "aws"
    }
  }
}
