# If there is no domain then don't create anything
locals {
  count = var.domain != "" ? 1 : 0
}

resource "aws_acm_certificate" "cert" {
  count = local.count
  domain_name       = var.domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_zone" "main" {
  count = local.count
  name = var.domain
}

resource "aws_route53_record" "cert_validation" {
  count = local.count
  name    = aws_acm_certificate.cert.0.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.cert.0.domain_validation_options.0.resource_record_type
  zone_id = aws_route53_zone.main.0.id
  records = [aws_acm_certificate.cert.0.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  count = local.count
  certificate_arn         = aws_acm_certificate.cert.0.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.0.fqdn]
}