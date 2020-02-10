
locals {
  cert_count = var.domain != "" ? 1 : 0
  s3_origin_id = "${var.stage}-${var.service}-s3OriginId"
}

resource "aws_route53_record" "cdn-alias" {
  count = local.cert_count
  zone_id = var.zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_s3_bucket" "b" {
  bucket = "${var.stage}-${var.service}"
  acl    = "private"
  force_destroy = true
}

resource "aws_cloudfront_origin_access_identity" "default" {
  comment = "Origin Access Identity"
}

resource "aws_s3_bucket_policy" "b" {
  bucket = aws_s3_bucket.b.id

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

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.b.bucket_regional_domain_name
    origin_id = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path
    }
  }

  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

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

    lambda_function_association {
      event_type   = "origin-response"
      lambda_arn   = var.origin_response_lambda_arn
      include_body = false
    }
  }

  ordered_cache_behavior {
    path_pattern     = "/_next/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

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

    lambda_function_association {
      event_type   = "origin-response"
      lambda_arn   = var.origin_response_lambda_arn
      include_body = false
    }
  }
  
  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = local.cert_count == 1 ? false : true
    acm_certificate_arn      = local.cert_count == 1 ? var.certificate_arn : ""
    ssl_support_method       = local.cert_count == 1 ? "sni-only" : ""
    minimum_protocol_version = "TLSv1"
  }

  aliases = local.cert_count == 1 ? [var.domain] : []

  tags = {
      Name    = "${var.stage}-${var.service}"
      Stage   = var.stage
      Service = var.service
  }
}