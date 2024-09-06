# ## All the variables used must be present here
variable "vpc_id" {
  type        = string
  description = "VPC ID where the SMTP VPC endpoints will be deployed"
}

variable "domain" {
  type        = string
  description = "Domain used for SES mail sending. Domain DNS must be in Route53 in the same account as the SES"
}

variable "behavior_on_mx_failure" {
  type        = string
  description = "The action that you want Amazon SES to take if it cannot successfully read the required MX record when you send an email."
  default     = "UseDefaultValue"
}

variable "ses_smtp_user" {
  type        = string
  description = "Name of the user created to authenticate to SES SMTP relay."
}

variable "name" {
  type        = string
  description = "name used to tag resources"
}

variable "tags" {
  type        = map(string)
  description = "Tags to associate with SES resources"
  default     = {}
}

variable "ses_endpoint_failover" {
  type        = bool
  description = "Determines whether the SES VPC endpoint is deployed in a single AZ or multiple"
  default     = false
}

variable "allowed_cidr" {
  type        = string
  description = "CIDR authorised to use the SES SMTP relay VPC endpoint."
  default     = ""
}
