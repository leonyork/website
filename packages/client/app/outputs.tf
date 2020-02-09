output "redirect_url" {
  value = local.auth_demo_location
}
output "logout_url" {
  value = local.auth_demo_location
}
output "s3_bucket_id" {
  value = aws_s3_bucket.b.id
}
output "domain_name" {
  value = var.domain != "" ? var.domain : aws_cloudfront_distribution.s3_distribution.domain_name
}