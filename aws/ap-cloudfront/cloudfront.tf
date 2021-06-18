provider "aws" {
  alias   = "east"
  version = "~> 2.8"
  region  = "us-east-1"
}

data "aws_route53_zone" "hosted_zone" {
  provider = aws.east
  name     = var.host_zone
}
data "aws_acm_certificate" "cloudfront_certificate" {
  provider = aws.east
  domain   = "cdn.${var.host_zone}"
}
data "aws_wafv2_web_acl" "wordpress" {
  provider = aws.east
  name     = "wordpress-protection"
  scope    = "CLOUDFRONT"
}

# resource "aws_acm_certificate" "cloudfront_certificate" {
#   provider                  = aws.east
#   domain_name               = "cdn.${var.host_zone}"
#   validation_method         = "DNS"
#   subject_alternative_names = concat(["*.${var.host_zone}"], var.sbj_alt_names)
#   tags = {
#     Environment = var.environment
#   }
#   lifecycle {
#     create_before_destroy = true
#   }
# }
# resource "aws_route53_record" "cloudfront_certificate" {
#   provider        = aws.east
#   allow_overwrite = true
#   name            = aws_acm_certificate.cloudfront_certificate.domain_validation_options[0].resource_record_name
#   records         = [aws_acm_certificate.cloudfront_certificate.domain_validation_options[0].resource_record_value]
#   ttl             = 60
#   type            = aws_acm_certificate.cloudfront_certificate.domain_validation_options[0].resource_record_type
#   zone_id         = data.aws_route53_zone.hosted_zone.zone_id
# }
# resource "aws_route53_record" "alternate_cloudfront_certificate" {
#   provider        = aws.east
#   allow_overwrite = true
#   name            = aws_acm_certificate.cloudfront_certificate.domain_validation_options[1].resource_record_name
#   records         = [aws_acm_certificate.cloudfront_certificate.domain_validation_options[1].resource_record_value]
#   ttl             = 60
#   type            = aws_acm_certificate.cloudfront_certificate.domain_validation_options[1].resource_record_type
#   zone_id         = data.aws_route53_zone.hosted_zone.zone_id
# }
# resource "aws_acm_certificate_validation" "cloudfront_certificate" {
#   provider                = aws.east
#   certificate_arn         = aws_acm_certificate.cloudfront_certificate.arn
#   validation_record_fqdns = [aws_route53_record.cloudfront_certificate.fqdn, aws_route53_record.alternate_cloudfront_certificate.fqdn]
#   depends_on = [
#     aws_route53_record.cloudfront_certificate,
#     aws_route53_record.alternate_cloudfront_certificate
#   ]
# }

resource "aws_cloudfront_distribution" "cloudfront" {
  provider   = aws.east
  count      = ceil(length(var.domains) / 97)
  web_acl_id = data.aws_wafv2_web_acl.wordpress
  origin {
    domain_name = var.origin
    origin_id   = var.origin
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  enabled = true
  aliases = [for num in range(97 * count.index, min(97 * (count.index + 1), length(var.domains))) : var.domains[num]]

  tags = {
    Environment = var.environment
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = data.aws_acm_certificate.cloudfront_certificate.arn
    ssl_support_method             = "sni-only"
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"] # ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]                                              # ["GET", "HEAD"]
    target_origin_id = var.origin

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all" #"all"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
  }
  restrictions {

    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_route53_record" "networks" {
  provider = aws.east
  for_each = toset(var.domains)
  zone_id  = data.aws_route53_zone.hosted_zone.zone_id
  name     = each.key
  type     = "CNAME"
  ttl      = "5"
  records  = [aws_cloudfront_distribution.cloudfront[floor(length(var.domains) / 97)].domain_name]
}

###################################################
#### Cloudfront and certs for customer domains ####
###################################################

resource "aws_acm_certificate" "vanity_domains_CF_cert" {
  provider                  = aws.east
  for_each                  = var.vanity_domains
  domain_name               = each.value
  validation_method         = "DNS"
  subject_alternative_names = [each.key]
  tags = {
    Environment = var.environment
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "alternate_vanity_certificate" {
  provider        = aws.east
  for_each        = var.vanity_domains
  allow_overwrite = true
  name            = aws_acm_certificate.vanity_domains_CF_cert[each.key].domain_validation_options[0].resource_record_name
  records         = [aws_acm_certificate.vanity_domains_CF_cert[each.key].domain_validation_options[0].resource_record_value]
  ttl             = 60
  type            = aws_acm_certificate.vanity_domains_CF_cert[each.key].domain_validation_options[0].resource_record_type
  zone_id         = data.aws_route53_zone.hosted_zone.zone_id
}

resource "aws_cloudfront_distribution" "vanity_domains_CF" {
  provider = aws.east
  for_each = var.validated_vanity_domains
  origin {
    domain_name = var.origin
    origin_id   = var.origin
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  enabled = true
  aliases = [each.key, each.value]

  tags = {
    Environment = var.environment
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.vanity_domains_CF_cert[each.key].arn
    ssl_support_method             = "sni-only"
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"] # ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]                                              # ["GET", "HEAD"]
    target_origin_id = var.origin

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all" #"all"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
  }
  restrictions {

    geo_restriction {
      restriction_type = "none"
    }
  }
}
resource "aws_route53_record" "vanity_domains" {
  provider = aws.east
  for_each = var.validated_vanity_domains
  zone_id  = data.aws_route53_zone.hosted_zone.zone_id
  name     = each.value
  type     = "CNAME"
  ttl      = "5"
  records  = [aws_cloudfront_distribution.vanity_domains_CF[each.key].domain_name]
}
