resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  chart      = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  version    = var.cluster_autoscaler_plugin_config.chart_version
  namespace  = kubernetes_namespace.vcl_system.metadata.0.name

  max_history = 15
  atomic      = true
  wait        = true
  timeout     = 600

  values = [yamlencode(local.cluster_autoscaler_helm_values)]
}

locals {
  cluster_autoscaler_helm_values = {
    image = {
      repository = var.cluster_autoscaler_plugin_config.image_repo
      tag        = var.cluster_autoscaler_plugin_config.image_tag
    }

    replicas = var.cluster_autoscaler_plugin_config.deployment_replicas

    rbac = {
      create = "true"
      serviceAccount = {
        name   = var.cluster_autoscaler_plugin_config.service_account
        create = "true"
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.eks_service_account_aws_role.arn
        }
      }
    }

    nodeSelector      = var.cluster_autoscaler_plugin_config.node_selector
    priorityClassName = "system-cluster-critical"

    autoDiscovery = {
      clusterName = var.aws_eks_cluster_name
    }

    extraArgs = {
      balance-similar-node-groups = false
    }

    awsRegion = var.cluster_autoscaler_plugin_config.aws_region
  }

  cluster_autoscaler_tags = merge(
    {
      "UsedBy" = "cluster-autoscaler"
    },
    var.tags
  )

}


data "aws_iam_policy_document" "cluster_autoscaler_aws_role_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.aws_eks_cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${kubernetes_namespace.vcl_system.metadata.0.name}:${var.cluster_autoscaler_plugin_config.service_account}"]
    }

    principals {
      identifiers = [var.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

data "aws_iam_policy_document" "cluster_autoscaler_policy" {
  statement {
    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values = [
        "true"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${var.aws_eks_cluster_name}"
      values = [
        "owned"
      ]
    }
  }
  statement {
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:DescribeInstanceTypes"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "eks_service_account_aws_role" {
  name               = "eks-${var.aws_eks_cluster_name}-cluster-autoscaler"
  description        = "EKS ${var.aws_eks_cluster_name} cluster-autoscaler role"
  assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler_aws_role_assume.json

  inline_policy {
    name   = "cluster-autoscaler-policy"
    policy = data.aws_iam_policy_document.cluster_autoscaler_policy.json
  }

  tags = local.cluster_autoscaler_tags
}
