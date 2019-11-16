variable "region" {
  default = "us-east-1"
}
variable "stage" {
  default = "dev"
}
variable "service" {
  default = "leonyork-com"
}
variable "domain" {
  default = "leonyork.com"
}
variable "build" {
  default = "out"
}

provider "aws" {
  region = "${var.region}"
  shared_credentials_file = "~/.aws/credentials"
}

terraform {
  backend "s3" {
    bucket = "prod-leonyork-com-terraform"
    key    = "terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    shared_credentials_file = "~/.aws/credentials"
  }
}

resource "aws_s3_bucket" "b" {
  bucket = "${var.stage}-${var.service}"
  acl    = "private"
  force_destroy = true
}

locals {
  s3_origin_id = "${var.stage}-${var.service}-s3OriginId"
}

resource "aws_cloudfront_origin_access_identity" "default" {
  comment = "Origin Access Identity"
}

resource "aws_s3_bucket_policy" "b" {
  bucket = "${aws_s3_bucket.b.id}"

  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Statement": [
      {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": {
          "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.default.id}"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.b.id}/*"
      }
  ]
}
POLICY
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.domain}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_zone" "main" {
  name = "${var.domain}"
}

resource "aws_route53_record" "cert_validation" {
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${aws_route53_zone.main.id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.b.bucket_regional_domain_name}"
    origin_id = "${local.s3_origin_id}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path}"
    }
  }

  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "/_next/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 31536000
    default_ttl            = 31536000
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }
  
  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "${aws_acm_certificate_validation.cert.certificate_arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }

  aliases = ["${var.domain}"]

  tags = {
      Name    = "${var.stage}-${var.service}"
      Stage   = "${var.stage}"
      Service = "${var.service}"
  }
}

resource "aws_route53_record" "cdn-alias" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "${var.domain}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.s3_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}

#Do this after the s3 distribution is applied so that we ensure we invalidate the distribution without having to recreate
resource "null_resource" "remove_and_upload_to_s3" {
  depends_on = ["aws_cloudfront_distribution.s3_distribution"]
  #Ensure we run this build and deploy every time - even if the other resources didn't need to be changed - This is a known hack - see https://www.kecklers.com/terraform-null-resource-execute-every-time/ and https://github.com/hashicorp/terraform/pull/3244
  triggers = {
      build_number = "${timestamp()}"
  }

  # Always sync up index.html whether the size has changed or not. 
  # For speed, don't sync up files that sizes haven't changed (e.g. static files that could be larger)
  # Always invalidate the cloudfront cache, even if we've just created it - for simpleness
  # Only delete after updating index.html and invalidating cloudfront so the new files definitely exist
  provisioner "local-exec" {
    command = <<EOF
    aws s3 sync ${var.build}/_next s3://${aws_s3_bucket.b.id}/_next --region=${var.region} --size-only --cache-control "max-age=31557600" && \
    aws s3 sync ${var.build}/fonts s3://${aws_s3_bucket.b.id}/fonts --region=${var.region} --size-only --cache-control "max-age=31557600" && \
    aws s3 sync ${var.build} s3://${aws_s3_bucket.b.id} --region=${var.region} --size-only --cache-control "no-store, no-cache, must-revalidate" && \
    aws s3 cp ${var.build}/index.html s3://${aws_s3_bucket.b.id}/index.html --region=${var.region}  --cache-control "no-store, no-cache, must-revalidate" && \
    aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.s3_distribution.id} --paths /index.html --region=${var.region} && \
    aws s3 sync ${var.build} s3://${aws_s3_bucket.b.id} --region=${var.region} --size-only --delete
    EOF
  }
}