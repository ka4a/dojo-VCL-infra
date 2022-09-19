locals {
  # There is a limit of 5 conditions per rule
  vcl_allowed_endpoints = chunklist([
    "/api/v1*",
    "/admin*",
    "/assignment*",
    "/lti*",
    "/readiness*",
    "/healthz*",
    "/web-static*"
  ], 5)
}

resource "aws_lb" "this" {
  name = var.name

  internal           = var.internal
  load_balancer_type = "application"

  ip_address_type = "ipv4"
  security_groups = var.security_groups
  subnets         = var.subnets

  tags = var.tags
}

resource "aws_lb_target_group" "vcl_core" {
  name = "vcl-core-${var.env}"

  deregistration_delay = "60"
  port                 = 8000
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.vpc_id

  health_check {
    path = "/swagger/"
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "vcl_workspaces" {
  name = "vcl-workspaces-${var.env}"

  deregistration_delay = "60"
  port                 = 8000
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.vpc_id

  health_check {
    path                = "/ping"
    port                = "9000"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 10
    timeout             = 5
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "http" {
  port              = 80
  protocol          = "HTTP"
  load_balancer_arn = aws_lb.this.arn

  default_action {
    type = "redirect"

    redirect {
      status_code = "HTTP_301"
      protocol    = "HTTPS"
      port        = "443"
    }
  }

  tags = var.tags
}

resource "aws_lb_listener" "https" {
  certificate_arn   = var.acm_arn
  port              = 443
  protocol          = "HTTPS"
  load_balancer_arn = aws_lb.this.arn
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }

  tags = var.tags
}

resource "aws_lb_listener_rule" "vcl_allowed_endpoints" {
  for_each = { for chunk in local.vcl_allowed_endpoints : index(local.vcl_allowed_endpoints, chunk) => chunk }

  listener_arn = aws_lb_listener.https.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vcl_core.arn
  }

  condition {
    path_pattern {
      values = each.value
    }
  }

  tags = var.tags
}


resource "aws_lb_listener_rule" "workspace" {
  listener_arn = aws_lb_listener.https.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vcl_workspaces.arn
  }

  condition {
    path_pattern {
      values = ["/workspace/*"]
    }
  }

  tags = var.tags
}
