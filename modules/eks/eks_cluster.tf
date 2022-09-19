#---------------------------------------------------
# AWS EKS cluster
#---------------------------------------------------
resource "aws_eks_cluster" "eks_cluster" {
  count = var.create_eks_cluster ? 1 : 0

  name     = var.eks_cluster_name != "" ? lower(var.eks_cluster_name) : "${lower(var.name)}-eks-${lower(var.environment)}"
  role_arn = var.eks_cluster_role_arn

  dynamic "vpc_config" {
    iterator = vpc_config
    for_each = var.eks_cluster_vpc_config

    content {
      subnet_ids = lookup(vpc_config.value, "subnet_ids", null)

      public_access_cidrs     = lookup(vpc_config.value, "public_access_cidrs", null)
      endpoint_private_access = lookup(vpc_config.value, "endpoint_private_access", null)
      endpoint_public_access  = lookup(vpc_config.value, "endpoint_public_access", null)
      security_group_ids      = lookup(vpc_config.value, "security_group_ids", null)
    }
  }

  enabled_cluster_log_types = var.eks_cluster_enabled_cluster_log_types
  version                   = var.eks_cluster_version

  dynamic "encryption_config" {
    iterator = encryption_config
    for_each = var.eks_cluster_encryption_config

    content {
      resources = lookup(encryption_config.value, "resources", null)

      dynamic "provider" {
        iterator = provider
        for_each = length(keys(lookup(encryption_config.value, "provider", {}))) > 0 ? [lookup(encryption_config.value, "provider", {})] : []

        content {
          key_arn = lookup(provider.value, "key_arn", null)
        }
      }
    }
  }

  dynamic "timeouts" {
    iterator = timeouts
    for_each = length(keys(var.eks_cluster_timeouts)) > 0 ? [var.eks_cluster_timeouts] : []

    content {
      create = lookup(timeouts.value, "create", null)
      update = lookup(timeouts.value, "update", null)
      delete = lookup(timeouts.value, "delete", null)
    }
  }

  tags = merge(
    {
      Name = var.eks_cluster_name != "" ? lower(var.eks_cluster_name) : "${lower(var.name)}-eks-${lower(var.environment)}"
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
    ignore_changes        = []
  }

  depends_on = []
}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.eks_cluster[0].identity[0].oidc[0].issuer
}

data "aws_partition" "current" {
}

data "aws_region" "current" {
}

data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = distinct(compact(concat(["sts.${data.aws_partition.current.dns_suffix}"], [""])))
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_cluster[0].identity[0].oidc[0].issuer

  tags = merge(
    {
      Name = var.eks_cluster_name != "" ? lower(var.eks_cluster_name) : "${lower(var.name)}-eks-${lower(var.environment)}"
    },
    var.tags
  )
}

resource "aws_iam_role" "sa_vcl_web" {
  count = var.core_cluster ? 1 : 0

  name               = "eks-${var.eks_cluster_name}-sa-web"
  description        = "EKS ${var.eks_cluster_name} SA role for VCL Web"
  assume_role_policy = data.aws_iam_policy_document.sa_vcl_web_assume.0.json

  tags = merge(
    {
      Name = var.eks_cluster_name != "" ? lower(var.eks_cluster_name) : "${lower(var.name)}-eks-${lower(var.environment)}"
    },
    var.tags
  )
}

data "aws_iam_policy_document" "sa_vcl_web_assume" {
  count = var.core_cluster ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_eks_cluster.eks_cluster[0].identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:vcl-core:vcl-core"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc_provider.arn]
      type        = "Federated"
    }
  }
}

data "aws_iam_policy_document" "sa_vcl_web" {
  count = var.core_cluster ? 1 : 0

  statement {
    sid       = "WorkspacesEKS"
    effect    = "Allow"
    actions   = ["eks:*"]
    resources = ["arn:aws:eks:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/vcl-workspaces-${var.environment}"]
  }

  statement {
    sid    = "ManageEBS"
    effect = "Allow"
    actions = [
      "ec2:AttachVolume",
      "ec2:DescribeVolumeStatus",
      "ec2:CreateTags",
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumeAttribute",
      "ec2:CreateVolume"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "sa_vcl_web" {
  count = var.core_cluster ? 1 : 0

  name        = "eks-${var.eks_cluster_name}-sa-web"
  description = "EKS ${var.eks_cluster_name} SA policy for VCL Web"
  policy      = data.aws_iam_policy_document.sa_vcl_web.0.json
}

resource "aws_iam_role_policy_attachment" "sa_vcl_web" {
  count = var.core_cluster ? 1 : 0

  policy_arn = aws_iam_policy.sa_vcl_web.0.arn
  role       = aws_iam_role.sa_vcl_web.0.name
}
