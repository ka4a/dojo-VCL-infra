resource "aws_security_group" "rabbitmq" {
  name        = "${var.name_prefix}-rabbitmq"
  description = "Security Group for RabbitMQ"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "AMQP from within VPC"
    from_port   = 5671
    protocol    = "tcp"
    to_port     = 5671
    cidr_blocks = [aws_vpc.this.cidr_block]
  }

  ingress {
    description = "HTTPS from within VPC"
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = [aws_vpc.this.cidr_block]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    "Name" = "${var.name_prefix}-rabbitmq"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "postgresql" {
  name        = "${var.name_prefix}-postgresql"
  description = "Security Group for Postgresql"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Postgresql from within VPC"
    from_port   = 5432
    protocol    = "tcp"
    to_port     = 5432
    cidr_blocks = [aws_vpc.this.cidr_block]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    "Name" = "${var.name_prefix}-postgresql"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "redis" {
  name        = "${var.name_prefix}-redis"
  description = "Security Group for Redis"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Redis from within VPC"
    from_port   = 6379
    protocol    = "tcp"
    to_port     = 6379
    cidr_blocks = [aws_vpc.this.cidr_block]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    "Name" = "${var.name_prefix}-redis"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "alb_public" {
  name        = "${var.name_prefix}-alb-public"
  description = "Security Group for internet-facing ALB"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTP from the Internet"
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = length(var.allowed_ips) == 0 ? ["0.0.0.0/0"] : var.allowed_ips
  }

  ingress {
    description = "HTTPS from the Internet"
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = length(var.allowed_ips) == 0 ? ["0.0.0.0/0"] : var.allowed_ips
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    "Name" = "${var.name_prefix}-alb-public"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "alb_private" {
  name        = "${var.name_prefix}-alb-private"
  description = "Security Group for internal ALB"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTP from within VPC"
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = [aws_vpc.this.cidr_block]
  }

  ingress {
    description = "HTTPS from within VPC"
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = [aws_vpc.this.cidr_block]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    "Name" = "${var.name_prefix}-alb-private"
  })

  lifecycle {
    create_before_destroy = true
  }
}

