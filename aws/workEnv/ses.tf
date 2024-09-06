# /*
# Create SES domain identity and verify it with Route53 DNS records
# */

# data "aws_route53_zone" "selected" {
#   name = "pwaws.cloudops.net."
#   # private_zone = false
# }

# resource "aws_ses_domain_identity" "ses_domain" {
#   domain = "pwaws.cloudops.net"
# }

# resource "aws_route53_record" "amazonses_verification_record" {

#   zone_id = data.aws_route53_zone.selected.zone_id
#   name    = "_amazonses.pwaws.cloudops.net"
#   type    = "TXT"
#   ttl     = "1800"
#   records = [join("", aws_ses_domain_identity.ses_domain[*].verification_token)]
# }

# resource "aws_ses_domain_dkim" "ses_domain_dkim" {
#   domain = join("", aws_ses_domain_identity.ses_domain[*].domain)
# }

# resource "aws_route53_record" "amazonses_dkim_record" {
#   count = 3

#   zone_id = data.aws_route53_zone.selected.zone_id
#   name    = "${element(aws_ses_domain_dkim.ses_domain_dkim.dkim_tokens, count.index)}._domainkey.pwaws.cloudops.net"
#   type    = "CNAME"
#   ttl     = "1800"
#   records = ["${element(aws_ses_domain_dkim.ses_domain_dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
# }

# resource "aws_route53_record" "amazonses_spf_record" {
#   zone_id = data.aws_route53_zone.selected.zone_id
#   name    = join("", aws_ses_domain_identity.ses_domain[*].domain)
#   type    = "TXT"
#   ttl     = "3600"
#   records = ["v=spf1 include:amazonses.com -all"]
# }

# resource "aws_ses_domain_mail_from" "custom_mail_from" {
#   domain                 = join("", aws_ses_domain_identity.ses_domain[*].domain)
#   mail_from_domain       = "mail.${join("", aws_ses_domain_identity.ses_domain[*].domain)}"
#   behavior_on_mx_failure = "UseDefaultValue"
# }

# # data "aws_region" "current" {}

# resource "aws_route53_record" "custom_mail_from_mx" {
#   zone_id = data.aws_route53_zone.selected.zone_id
#   name    = join("", aws_ses_domain_mail_from.custom_mail_from[*].mail_from_domain)
#   type    = "MX"
#   ttl     = "600"
#   records = ["10 feedback-smtp.${join("", data.aws_region.current[*].name)}.amazonses.com"]
# }

# #-----------------------------------------------------------------------------------------------------------------------
# # CREATE A USER FOR SMTP
# #-----------------------------------------------------------------------------------------------------------------------

# data "aws_iam_policy_document" "ses_policy" {
#   statement {
#     actions   = ["ses:SendRawEmail"]
#     resources = ["*"]
#   }
# }

# resource "aws_iam_group" "ses_users" {
#   name = "pw-croesus-ses-poc"
#   path = "/"
# }

# resource "aws_iam_group_policy" "ses_group_policy" {
#   name  = "pw-croesus-ses-poc"
#   group = aws_iam_group.ses_users.name

#   policy = join("", data.aws_iam_policy_document.ses_policy[*].json)
# }

# resource "aws_iam_user_group_membership" "ses_user" {
#   user = aws_iam_user.ses.id

#   groups = [
#     aws_iam_group.ses_users.name
#   ]
# }

# resource "aws_iam_user" "ses" {
#   name = "pw-croesus-poc-smtp"
# }

# resource "aws_iam_access_key" "ses_key" {
#   user = aws_iam_user.ses.name
# }

# ### This value will only be visible when using the `terraform output smtp_password` command
# output "smtp_password" {
#   sensitive = true
#   value     = aws_iam_access_key.ses_key.ses_smtp_password_v4
# }

# #-----------------------------------------------------------------------------------------------------------------------
# # CREATE A VPC ENDPOINT FOR SES
# #-----------------------------------------------------------------------------------------------------------------------

# resource "aws_vpc_endpoint" "ses" {
#   vpc_id             = aws_vpc.vpc.id
#   vpc_endpoint_type  = "Interface"
#   service_name       = "com.amazonaws.${data.aws_region.current.id}.email-smtp"
#   security_group_ids = [aws_security_group.ses_vpc_endpoint.id]
#   subnet_ids         = [aws_subnet.private_subnets[0].id, aws_subnet.private_subnets[1].id]
# dynamic "subnet_configuration" {
#   for_each = toset([aws_subnet.private_subnets[0], aws_subnet.private_subnets[1]])
#   content {
#     subnet_id = subnet_configuration.value.id
#     ipv4      = cidrhost(subnet_configuration.value.cidr_block, 25)
#   }
# }
#   tags = {
#     Name = "pw-croesus-ses-poc"
#   }
# }

# resource "aws_security_group" "ses_vpc_endpoint" {
#   name        = "smtp_vpc_endpoint"
#   description = "Allow SMTP inbound traffic"
#   vpc_id      = aws_vpc.vpc.id

#   tags = {
#     Name = "allow_smtp"
#   }
# }

# resource "aws_vpc_security_group_ingress_rule" "ses_smtp_465" {
#   security_group_id = aws_security_group.ses_vpc_endpoint.id
#   cidr_ipv4         = aws_vpc.vpc.cidr_block
#   from_port         = 465
#   ip_protocol       = "tcp"
#   to_port           = 465
# }
# resource "aws_vpc_security_group_ingress_rule" "ses_smtp_587" {
#   security_group_id = aws_security_group.ses_vpc_endpoint.id
#   cidr_ipv4         = aws_vpc.vpc.cidr_block
#   from_port         = 587
#   ip_protocol       = "tcp"
#   to_port           = 587
# }
