# ### Certs for openVPN
# data "aws_partition" "current" {}

# resource "aws_acmpca_certificate_authority" "example" {
#   type = "ROOT"
#   certificate_authority_configuration {
#     key_algorithm     = "RSA_2048"
#     signing_algorithm = "SHA512WITHRSA"

#     subject {
#       common_name = "advancednutrient"
#     }
#   }
# }

# resource "aws_acmpca_permission" "example" {
#   certificate_authority_arn = aws_acmpca_certificate_authority.example.arn
#   actions                   = ["IssueCertificate", "GetCertificate", "ListPermissions"]
#   principal                 = "acm.amazonaws.com"
# }

# resource "aws_acmpca_certificate" "example" {
#   certificate_authority_arn   = aws_acmpca_certificate_authority.example.arn
#   certificate_signing_request = aws_acmpca_certificate_authority.example.certificate_signing_request
#   signing_algorithm           = "SHA256WITHRSA"

#   template_arn = "arn:${data.aws_partition.current.partition}:acm-pca:::template/RootCACertificate/V1"
#   validity {
#     type  = "YEARS"
#     value = 10
#   }
# }

# resource "aws_acmpca_certificate_authority_certificate" "example" {
#   certificate_authority_arn = aws_acmpca_certificate_authority.example.arn

#   certificate       = aws_acmpca_certificate.example.certificate
#   certificate_chain = aws_acmpca_certificate.example.certificate_chain
# }

# resource "aws_acm_certificate" "cert" {
#   domain_name               = "pwaws.cloudops.net"
#   certificate_authority_arn = aws_acmpca_certificate_authority.example.arn
# }

# resource "aws_ec2_client_vpn_endpoint" "vpn" {
#   description            = "VPN endpoint"
#   server_certificate_arn = aws_acm_certificate.cert.arn
#   client_cidr_block      = "10.128.252.0/22"
#   split_tunnel           = true
#   transport_protocol     = "tcp"

#   authentication_options {
#     type                       = "certificate-authentication"
#     root_certificate_chain_arn = aws_acm_certificate.cert.arn
#   }
#   connection_log_options {
#     enabled = false
#   }
# }
