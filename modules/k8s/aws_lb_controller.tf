resource "helm_release" "aws_lb_controller" {
  name        = "aws-lb-controller"
  chart       = "aws-load-balancer-controller"
  repository  = "https://aws.github.io/eks-charts"
  version     = var.aws_lb_controller_config.chart_version
  namespace   = kubernetes_namespace.vcl_system.metadata.0.name
  max_history = 15
  atomic      = true
  wait        = true
  timeout     = 600

  values = [yamlencode(local.aws_lb_controller_helm_values)]

  depends_on = [aws_iam_role_policy_attachment.aws_lb_controller]
}

resource "local_file" "vcl_web_tgb_manifest" {
  count = var.core_cluster ? 1 : 0

  filename = "${path.module}/tmp/vcl-web-tgb.yaml"
  content = templatefile("${path.module}/files/target-group-binding.tftpl",
    local.vcl_web_tgb_manifest_template_values
  )
}

resource "null_resource" "vcl_web_tgb_manifest" {
  count = var.core_cluster ? 1 : 0

  triggers = {
    template_file_base64      = filebase64("${path.module}/files/target-group-binding.tftpl")
    template_namespace        = local.vcl_web_tgb_manifest_template_values.namespace
    template_service_name     = local.vcl_web_tgb_manifest_template_values.service_name
    template_service_port     = local.vcl_web_tgb_manifest_template_values.service_port
    template_target_group_arn = local.vcl_web_tgb_manifest_template_values.target_group_arn
    template_tgb_name         = local.vcl_web_tgb_manifest_template_values.tgb_name
    target_group_arn          = var.tgb_target_group_arn
  }

  provisioner "local-exec" {
    working_dir = path.module

    environment = {
      KUBECONFIG = local.kubeconfig_filename
    }

    command = "kubectl apply -f tmp/vcl-web-tgb.yaml"
  }

  depends_on = [
    null_resource.kubeconfig,
    helm_release.aws_lb_controller,
    local_file.vcl_web_tgb_manifest[0]
  ]
}

resource "local_file" "traefik_tgb_manifest" {
  count = var.core_cluster ? 0 : 1

  filename = "${path.module}/tmp/traefik-tgb.yaml"
  content = templatefile("${path.module}/files/target-group-binding.tftpl",
    local.traefik_tgb_manifest_template_values
  )
}

resource "null_resource" "traefik_tgb_manifest" {
  count = var.core_cluster ? 0 : 1

  triggers = {
    template_file_base64      = filebase64("${path.module}/files/target-group-binding.tftpl")
    template_namespace        = local.traefik_tgb_manifest_template_values.namespace
    template_service_name     = local.traefik_tgb_manifest_template_values.service_name
    template_service_port     = local.traefik_tgb_manifest_template_values.service_port
    template_target_group_arn = local.traefik_tgb_manifest_template_values.target_group_arn
    template_tgb_name         = local.traefik_tgb_manifest_template_values.tgb_name
    target_group_arn          = var.tgb_target_group_arn
  }

  provisioner "local-exec" {
    working_dir = path.module

    environment = {
      KUBECONFIG = local.kubeconfig_filename
    }

    command = "kubectl apply -f tmp/traefik-tgb.yaml"
  }

  depends_on = [
    null_resource.kubeconfig,
    helm_release.aws_lb_controller,
    helm_release.traefik,
    local_file.traefik_tgb_manifest[0]
  ]
}

locals {
  vcl_web_tgb_manifest_template_values = {
    tgb_name         = "vcl-web-tgb"
    namespace        = kubernetes_namespace.vcl_core.metadata.0.name
    service_name     = "web"
    service_port     = "8080"
    target_group_arn = var.tgb_target_group_arn
  }

  traefik_tgb_manifest_template_values = {
    tgb_name         = "traefik-tgb"
    namespace        = kubernetes_namespace.vcl_system.metadata.0.name
    service_name     = "traefik"
    service_port     = "80"
    target_group_arn = var.tgb_target_group_arn
  }

  aws_lb_controller_iam_resources_name = "eks-${var.aws_eks_cluster_name}-aws-lb-controller"

  aws_lb_controller_helm_values = {

    clusterName = var.aws_eks_cluster_name

    enableCertManager = false
    ingressClass      = "alb"

    enablePodReadinessGateInject = true

    defaultTags = var.tags

    replicaCount = var.aws_lb_controller_config.deployment_replicas

    nodeSelector      = var.aws_lb_controller_config.node_selector
    priorityClassName = "system-cluster-critical"
    resources         = var.aws_lb_controller_config.controller_resources

    serviceAccount = {
      create = true
      name   = var.aws_lb_controller_config.service_account
      annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.aws_lb_controller.arn
      }
    }

    rbac = {
      create = true
    }
  }
}

data "aws_iam_policy_document" "aws_lb_controller_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.aws_eks_cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.system_namespace}:${var.aws_lb_controller_config.service_account}"]
    }

    principals {
      identifiers = [var.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "aws_lb_controller" {
  name               = local.aws_lb_controller_iam_resources_name
  description        = "EKS ${var.aws_eks_cluster_name} AWS LoadBalancer Controller role"
  assume_role_policy = data.aws_iam_policy_document.aws_lb_controller_assume.json

  tags = var.tags
}

resource "aws_iam_policy" "aws_lb_controller" {
  name        = local.aws_lb_controller_iam_resources_name
  description = "EKS ${var.aws_eks_cluster_name} AWS LoadBalancer Controller policy"
  policy      = data.aws_iam_policy_document.aws_lb_controller.json
}

resource "aws_iam_role_policy_attachment" "aws_lb_controller" {
  policy_arn = aws_iam_policy.aws_lb_controller.arn
  role       = aws_iam_role.aws_lb_controller.name
}

data "aws_iam_policy_document" "aws_lb_controller" {
  statement {
    effect = "Allow"
    actions = [
      "iam:CreateServiceLinkedRole",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeInstances",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeTags",
      "ec2:GetCoipPoolUsage",
      "ec2:DescribeCoipPools",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeSSLPolicies",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:DescribeTags"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "cognito-idp:DescribeUserPoolClient",
      "acm:ListCertificates",
      "acm:DescribeCertificate",
      "iam:ListServerCertificates",
      "iam:GetServerCertificate",
      "waf-regional:GetWebACL",
      "waf-regional:GetWebACLForResource",
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL",
      "wafv2:GetWebACL",
      "wafv2:GetWebACLForResource",
      "wafv2:AssociateWebACL",
      "wafv2:DisassociateWebACL",
      "shield:GetSubscriptionState",
      "shield:DescribeProtection",
      "shield:CreateProtection",
      "shield:DeleteProtection"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateSecurityGroup"
    ]
    resources = ["*"]
  }

  statement {
    effect  = "Allow"
    actions = ["ec2:CreateTags"]

    resources = ["arn:aws:ec2:*:*:security-group/*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values   = ["CreateSecurityGroup"]
    }

    condition {
      test     = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values   = [false]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateTags",
      "ec2:DeleteTags"
    ]

    resources = ["arn:aws:ec2:*:*:security-group/*"]

    condition {
      test     = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values   = [true]
    }

    condition {
      test     = "Null"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = [false]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:DeleteSecurityGroup"
    ]

    resources = ["*"]

    condition {
      test     = "Null"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = [false]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateTargetGroup"
    ]

    resources = ["*"]

    condition {
      test     = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values   = [false]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteRule"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags"
    ]

    resources = [
      "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
    ]

    condition {
      test     = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values   = [true]
    }

    condition {
      test     = "Null"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = [false]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags"
    ]

    resources = [
      "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
      "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
      "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
      "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:DeleteTargetGroup"
    ]

    resources = ["*"]

    condition {
      test     = "Null"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = [false]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets"
    ]

    resources = ["arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:SetWebAcl",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:RemoveListenerCertificates",
      "elasticloadbalancing:ModifyRule"
    ]

    resources = ["*"]
  }
}
