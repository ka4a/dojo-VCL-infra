resource "aws_db_instance" "default" {
  identifier                      = var.identifier
  allocated_storage               = var.storage
  engine                          = var.engine
  engine_version                  = var.engine_version
  instance_class                  = var.instance_class
  db_name                         = var.db_name
  username                        = var.username
  password                        = var.password
  vpc_security_group_ids          = [var.rds_security_group_id]
  db_subnet_group_name            = aws_db_subnet_group.default.id
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  storage_type                    = "gp2"
  backup_retention_period         = 7
  storage_encrypted               = false
  max_allocated_storage           = var.max_allocated_storage
  auto_minor_version_upgrade      = false
  performance_insights_enabled    = var.performance_insights_enabled
  skip_final_snapshot             = true
  publicly_accessible             = var.publicly_accessible

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_db_subnet_group" "default" {
  name        = var.name_prefix
  description = "${var.identifier} RDS subnet group"
  subnet_ids  = var.private_net_ids
}
