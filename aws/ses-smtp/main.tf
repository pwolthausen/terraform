/*
Create SES domain identity and verify it with Route53 DNS records
*/

resource "aws_ses_domain_identity" "ses_domain" {
  domain = var.domain
}

resource "aws_route53_record" "amazonses_verification_record" {

  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "_amazonses.${var.domain}"
  type    = "TXT"
  ttl     = "1800"
  records = [join("", aws_ses_domain_identity.ses_domain[*].verification_token)]
}

resource "aws_ses_domain_dkim" "ses_domain_dkim" {
  domain = join("", aws_ses_domain_identity.ses_domain[*].domain)
}

resource "aws_route53_record" "amazonses_dkim_record" {
  count = 3

  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${element(aws_ses_domain_dkim.ses_domain_dkim.dkim_tokens, count.index)}._domainkey.${var.domain}"
  type    = "CNAME"
  ttl     = "1800"
  records = ["${element(aws_ses_domain_dkim.ses_domain_dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

resource "aws_route53_record" "amazonses_spf_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = join("", aws_ses_domain_identity.ses_domain[*].domain)
  type    = "TXT"
  ttl     = "3600"
  records = ["v=spf1 include:amazonses.com -all"]
}

resource "aws_ses_domain_mail_from" "custom_mail_from" {
  domain                 = join("", aws_ses_domain_identity.ses_domain[*].domain)
  mail_from_domain       = "mail.${join("", aws_ses_domain_identity.ses_domain[*].domain)}"
  behavior_on_mx_failure = var.behavior_on_mx_failure
}

resource "aws_route53_record" "custom_mail_from_mx" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = join("", aws_ses_domain_mail_from.custom_mail_from[*].mail_from_domain)
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${join("", data.aws_region.current[*].name)}.amazonses.com"]
}

resource "aws_sesv2_dedicated_ip_pool" "ses_smtp" {
  pool_name = var.name
}

#-----------------------------------------------------------------------------------------------------------------------
# CREATE A USER FOR SMTP
#-----------------------------------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "ses_policy" {
  statement {
    actions   = ["ses:SendRawEmail"]
    resources = ["*"]
  }
}

resource "aws_iam_group" "ses_users" {
  name = var.ses_smtp_user
  path = "/"
}

resource "aws_iam_group_policy" "ses_group_policy" {
  name  = var.ses_smtp_user
  group = aws_iam_group.ses_users.name

  policy = join("", data.aws_iam_policy_document.ses_policy[*].json)
}

resource "aws_iam_user_group_membership" "ses_user" {
  user = aws_iam_user.ses.id

  groups = [
    aws_iam_group.ses_users.name
  ]
}

resource "aws_iam_user" "ses" {
  name = var.ses_smtp_user
}

resource "aws_iam_access_key" "ses_key" {
  user = aws_iam_user.ses.name
}

#-----------------------------------------------------------------------------------------------------------------------
# CREATE A VPC ENDPOINT FOR SES
#-----------------------------------------------------------------------------------------------------------------------

resource "aws_vpc_endpoint" "ses" {
  vpc_id             = data.aws_vpc.selected.id
  vpc_endpoint_type  = "Interface"
  service_name       = "com.amazonaws.${data.aws_region.current.id}.email-smtp"
  security_group_ids = [aws_security_group.ses_vpc_endpoint.id]
  ## using multiple subnets for the endpoint may cause errors as not all AZs are supported
  subnet_ids = local.endpoint_subnets[*].id
  dynamic "subnet_configuration" {
    for_each = toset(local.endpoint_subnets)
    content {
      subnet_id = subnet_configuration.value.id
      ipv4      = cidrhost(subnet_configuration.value.cidr_block, 25)
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name}-smtp-relay"
  })
}

resource "aws_security_group" "ses_vpc_endpoint" {
  name        = "smtp-relay-vpc-endpoint"
  description = "Allow SMTP inbound traffic"
  vpc_id      = data.aws_vpc.selected.id

  tags = merge(var.tags, {
    Name = "${var.name}allow-smtp"
  })
}

resource "aws_vpc_security_group_ingress_rule" "ses_smtp_465" {
  security_group_id = aws_security_group.ses_vpc_endpoint.id
  cidr_ipv4         = var.allowed_cidr == "" ? data.aws_vpc.selected.cidr_block : var.allowed_cidr
  from_port         = 465
  ip_protocol       = "tcp"
  to_port           = 465
}
resource "aws_vpc_security_group_ingress_rule" "ses_smtp_587" {
  security_group_id = aws_security_group.ses_vpc_endpoint.id
  cidr_ipv4         = var.allowed_cidr == "" ? data.aws_vpc.selected.cidr_block : var.allowed_cidr
  from_port         = 587
  ip_protocol       = "tcp"
  to_port           = 587
}

#-----------------------------------------------------------------------------------------------------------------------
#  SES OBSERVABILITY
#-----------------------------------------------------------------------------------------------------------------------

resource "aws_ses_configuration_set" "ses_smtp_events" {
  name                       = var.name
  reputation_metrics_enabled = true
}

resource "aws_ses_event_destination" "ses_smtp_sending_failure" {
  name                   = "${var.name}-sending-failure"
  configuration_set_name = aws_ses_configuration_set.ses_smtp_events.name
  enabled                = true
  matching_types         = ["bounce", "delivery", "renderingFailure"]

  cloudwatch_destination {
    default_value  = "delivery_failure"
    dimension_name = "ses_email_attempt"
    value_source   = "emailHeader"
  }
}

resource "aws_ses_event_destination" "ses_smtp_reputation" {
  name                   = "${var.name}-reputation-failure"
  configuration_set_name = aws_ses_configuration_set.ses_smtp_events.name
  enabled                = true
  matching_types         = ["reject", "complaint"]

  cloudwatch_destination {
    default_value  = "reputation_failure"
    dimension_name = "ses_email_attempt"
    value_source   = "emailHeader"
  }
}
