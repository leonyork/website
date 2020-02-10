output "redirect_url" {
  value = "https://${var.domain != "" ? var.domain : aws_cloudfront_distribution.s3_distribution.domain_name}/auth-demo"
}
output "logout_url" {
  value = "https://${var.domain != "" ? var.domain : aws_cloudfront_distribution.s3_distribution.domain_name}/auth-demo"
}
output "s3_bucket_id" {
  value = aws_s3_bucket.b.id
}
output "domain_name" {
  value = var.domain != "" ? var.domain : aws_cloudfront_distribution.s3_distribution.domain_name
}