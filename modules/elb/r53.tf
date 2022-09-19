data "aws_route53_zone" "this" {
  name         = "${var.domain_name}."
  private_zone = var.r53_hosted_zone_private
}

resource "aws_route53_record" "this" {
  name    = var.fully_qualified_domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.this.id

  alias {
    evaluate_target_health = false
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
  }
}
