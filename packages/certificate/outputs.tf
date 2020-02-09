output "domain" {
    value = var.domain
}
output "zone_id" {
    value = length(aws_route53_zone.main) == 1 ? aws_route53_zone.main.0.zone_id : ""
}
output "certificate_arn" {
    value = length(aws_acm_certificate_validation.cert) == 1 ? aws_acm_certificate_validation.cert.0.certificate_arn : ""
}