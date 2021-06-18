output vanity_name {
    value = tomap({for domain, record in aws_acm_certificate.vanity_domains_CF_cert : domain => record.domain_validation_options[1].resource_record_name})
}
output vanity_records {
    value = tomap({for domain, record in aws_acm_certificate.vanity_domains_CF_cert : domain => record.domain_validation_options[1].resource_record_value})
}
