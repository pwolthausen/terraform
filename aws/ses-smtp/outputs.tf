### This value will only be visible when using the `terraform output smtp_password` command
output "smtp_password" {
  sensitive = true
  value     = aws_iam_access_key.ses_key.ses_smtp_password_v4
}
