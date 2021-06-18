variable host_zone {}
variable origin {}
variable environment {}
variable domains {
  description = "List of domain names using this deployment. New route53 is created for each one"
  type        = list
}
variable vanity_domains {
  type = map
  description = "Map of vanity domains. The object name should be the customer vanity domain which contains the pressbooks domain"
  default     = {}
}

variable validated_vanity_domains {
  type = map
  description = "Map of validated vanity domains. The object name should be the customer vanity domain with a value of the client owned domain domain"
  default     = {}
}

# variable sbj_alt_names {
#   type        = list
#   description = "List of alternate names for the certificate being issued to cert manager. This can be completely different domains or subdomains for the current hosted zone"
#   default     = []
# }
