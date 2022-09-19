resource "aws_elasticache_cluster" "redis" {
  cluster_id           = var.cluster_id
  engine               = "redis"
  engine_version       = var.redis_version
  parameter_group_name = var.redis_parameter_group_name
  node_type            = var.redis_node_type
  num_cache_nodes      = 1 # redis doesn't support multiple nodes

  subnet_group_name        = aws_elasticache_subnet_group.vpc_subnet_group.name
  security_group_ids       = length(var.security_group_ids) > 0 ? var.security_group_ids : [aws_security_group.cache[0].id]
  port                     = var.redis_port
  snapshot_retention_limit = 1

  tags = var.tags
}

resource "aws_elasticache_subnet_group" "vpc_subnet_group" {
  name       = var.name_prefix
  subnet_ids = var.private_net_ids

  tags = var.tags
}

resource "aws_security_group" "cache" {
  count = length(var.security_group_ids) > 0 ? 0 : 1

  name   = "${var.name_prefix}-cache"
  vpc_id = var.vpc_id

  tags = var.tags
}

resource "aws_security_group_rule" "redis-outbound-rule" {
  count = length(var.security_group_ids) > 0 ? 0 : 1

  security_group_id = aws_security_group.cache[0].id
  type              = "egress"
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]

  from_port = 0
  to_port   = 0
}

resource "aws_security_group_rule" "redis-inbound-rule-vpc" {
  count = length(var.security_group_ids) > 0 ? 0 : 1

  type              = "ingress"
  security_group_id = aws_security_group.cache[0].id
  cidr_blocks       = [var.vpc_cidr]

  protocol  = "all"
  from_port = 6379
  to_port   = 6379
}

