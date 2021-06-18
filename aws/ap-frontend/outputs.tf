output host-sg {
    value = aws_security_group.web_server_security_group.id
}
output target_group {
    value = aws_lb_target_group.web_server_target_group.arn
}
output origin {
    value = aws_route53_record.lb.fqdn
}