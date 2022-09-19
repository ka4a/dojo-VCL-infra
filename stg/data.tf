data "aws_iam_policy_document" "ecr_common" {
  statement {
    sid    = "Allow Pull"
    effect = "Allow"
    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer"
    ]
    principals {
      type        = "AWS"
      identifiers = ["${var.ecr_allow_pull_entities}"]
    }
  }
  statement {
    sid    = "Allow Push"
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
    principals {
      type        = "AWS"
      identifiers = ["${var.ecr_allow_push_entities}"]
    }
  }
}

data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "eks_node_group_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_eks_cluster" "vcl_core" {
  name = module.eks_core.eks_cluster_id
}

data "aws_eks_cluster" "vcl_workspaces" {
  name = module.eks_workspaces.eks_cluster_id
}

data "aws_caller_identity" "current" {}

data "aws_acm_certificate" "acm" {
  domain = "*.${local.domain}"
}
