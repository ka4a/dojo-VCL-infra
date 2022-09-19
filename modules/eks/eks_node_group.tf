#---------------------------------------------------
# AWS EKS node group
#---------------------------------------------------
resource "aws_eks_node_group" "eks_node_group" {
  for_each = { for k, v in toset(var.eks_node_groups) : k.name => k }

  cluster_name    = var.eks_node_group_cluster_name != "" ? var.eks_node_group_cluster_name : (var.create_eks_cluster ? element(aws_eks_cluster.eks_cluster.*.name, 0) : null)
  node_group_name = each.value["name"]
  node_role_arn   = each.value["role_arn"]
  subnet_ids      = each.value["subnet_ids"]

  ami_type             = each.value["ami_type"]
  disk_size            = each.value["disk_size"]
  instance_types       = each.value["instance_types"]
  capacity_type        = lookup(each.value, "capacity_type", null)
  force_update_version = lookup(each.value, "force_update_version", null)
  labels               = try(each.value.labels, null)
  release_version      = lookup(each.value, "ami_release_version", null)
  version              = lookup(each.value, "version", null)

  scaling_config {
    desired_size = each.value["asg_desired_size"]
    max_size     = each.value["asg_max_size"]
    min_size     = each.value["asg_min_size"]
  }

  dynamic "remote_access" {
    iterator = remote_access
    for_each = length(lookup(each.value, "remote_access", [])) > 0 ? [each.value["remote_access"]] : []

    content {
      ec2_ssh_key               = lookup(remote_access.value, "ec2_ssh_key", null)
      source_security_group_ids = lookup(remote_access.value, "source_security_group_ids", null)
    }
  }

  dynamic "launch_template" {
    iterator = launch_template
    for_each = length(lookup(each.value, "launch_template", [])) > 0 ? [each.value["launch_template"]] : []

    content {
      id      = lookup(launch_template.value, "id", null)
      name    = lookup(launch_template.value, "name", null)
      version = lookup(launch_template.value, "version", null)
    }
  }

  dynamic "timeouts" {
    for_each = length(lookup(each.value, "timeouts", [])) > 0 ? [each.value["launch_template"]] : []

    content {
      create = lookup(timeouts.value, "create", null)
      update = lookup(timeouts.value, "update", null)
      delete = lookup(timeouts.value, "delete", null)
    }
  }

  update_config {
    max_unavailable_percentage = 50
  }

  tags = merge(
    {
      Name = each.value["name"] != "" ? lower(each.value["name"]) : "${lower(var.name)}-node-group-${lower(var.environment)}"
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = false
    ignore_changes        = [scaling_config.0.desired_size]
  }

  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}

data "aws_security_group" "eks_node_group_sg" {
  vpc_id = var.vpc_id

  tags = {
    "aws:eks:cluster-name" : var.eks_cluster_name
  }

  depends_on = [aws_eks_node_group.eks_node_group]
}

resource "aws_security_group_rule" "self_vpc" {
  description       = "Self VPC"
  from_port         = 0
  protocol          = "-1"
  security_group_id = data.aws_security_group.eks_node_group_sg.id
  to_port           = 0
  cidr_blocks       = [var.vpc_cidr]
  type              = "ingress"
}

resource "aws_autoscaling_group_tag" "nodegroup" {
  for_each = {
    for node_group in aws_eks_node_group.eks_node_group : node_group.node_group_name => { asg_name = flatten(node_group.resources.*.autoscaling_groups)[0].name }
  }

  autoscaling_group_name = each.value.asg_name

  tag {
    key   = "k8s.io/cluster-autoscaler/node-template/label/eks.amazonaws.com/nodegroup"
    value = each.key

    propagate_at_launch = false
  }

  depends_on = [aws_eks_node_group.eks_node_group]
}

resource "aws_autoscaling_group_tag" "instance_name" {
  for_each = {
    for node_group in aws_eks_node_group.eks_node_group : node_group.node_group_name => { cluster_name = node_group.cluster_name, asg_name = flatten(node_group.resources.*.autoscaling_groups)[0].name }
  }

  autoscaling_group_name = each.value.asg_name

  tag {
    key   = "Name"
    value = "${each.value.cluster_name}-eks-${each.key}"

    propagate_at_launch = true
  }

  depends_on = [aws_eks_node_group.eks_node_group]
}

resource "aws_autoscaling_group_tag" "env" {
  for_each = {
    for node_group in aws_eks_node_group.eks_node_group : node_group.node_group_name => { asg_name = flatten(node_group.resources.*.autoscaling_groups)[0].name }
  }

  autoscaling_group_name = each.value.asg_name

  tag {
    key   = "Env"
    value = var.environment

    propagate_at_launch = true
  }

  depends_on = [aws_eks_node_group.eks_node_group]
}
