locals {
  aws_auth_roles = concat([
    {
      groups   = ["system:bootstrappers", "system:nodes"]
      rolearn  = "arn:aws:iam::${var.aws_account_id}:role/${var.eks_node_group_iam_role}"
      username = "system:node:{{EC2PrivateDNSName}}"
    }
    ], var.aws_auth_map_roles
  )
}

resource "kubernetes_config_map_v1_data" "aws_auth" {
  count = var.manage_aws_auth ? 1 : 0

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles    = yamlencode(distinct(local.aws_auth_roles))
    mapUsers    = yamlencode(distinct(var.aws_auth_map_users))
    mapAccounts = yamlencode(distinct(var.aws_auth_map_accounts))
  }

  force = true

  depends_on = [var.aws_eks_cluster_endpoint]
}
