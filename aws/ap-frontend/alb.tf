resource "aws_acm_certificate" "web_server_alb_certificate" {
  domain_name       = "origin-lb.${var.name}.${var.region}.${var.host_zone}"
  validation_method = "DNS"
  tags = {
    environment = var.environment
    Domain      = var.name
  }
}

resource "aws_route53_record" "web_server_alb_certificate" {
  allow_overwrite = true
  name            = aws_acm_certificate.web_server_alb_certificate.domain_validation_options[0].resource_record_name
  records         = [aws_acm_certificate.web_server_alb_certificate.domain_validation_options[0].resource_record_value]
  ttl             = 60
  type            = aws_acm_certificate.web_server_alb_certificate.domain_validation_options[0].resource_record_type
  zone_id         = data.aws_route53_zone.hosted_zone.zone_id
}
resource "aws_acm_certificate_validation" "web_server_alb_certificate" {
  certificate_arn         = aws_acm_certificate.web_server_alb_certificate.arn
  validation_record_fqdns = [aws_route53_record.web_server_alb_certificate.fqdn]
}

resource "aws_route53_record" "lb" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "origin-lb.${var.name}.${var.region}.${var.host_zone}"
  type    = "A"

  alias {
    name                   = aws_lb.aws_lb.dns_name
    zone_id                = aws_lb.aws_lb.zone_id
    evaluate_target_health = true
  }
}

##################
### Create ALB ###
##################
resource "aws_security_group" "alb_security_group" {
  name        = "${var.name}-${var.environment}-alb-sg"
  description = "Load balancer for ${var.name} in ${var.environment} Security Group"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "${var.name}-${var.environment}-alb-sg"
    Environment = var.environment
  }
}

resource "aws_lb" "aws_lb" {
  name_prefix                      = "alb"
  internal                         = false
  load_balancer_type               = "application"
  subnets                          = tolist(data.aws_subnet_ids.public_subnet.ids)
  ip_address_type                  = "ipv4"
  enable_cross_zone_load_balancing = true
  security_groups                  = [aws_security_group.alb_security_group.id]

  tags = {
    Prefix      = "${var.name}-${var.environment}-alb"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "web_server_target_group" {
  name        = "${substr(var.name, 0, 12)}-${substr(var.environment, 0, 4)}-wb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = data.aws_vpc.vpc.id
  slow_start  = 60
  stickiness {
    type    = "lb_cookie"
    enabled = true
  }
  health_check {
    path                = "/"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200"
  }
}

resource "aws_lb_listener" "web_server_alb_listener" {
  load_balancer_arn = aws_lb.aws_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.web_server_alb_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_server_target_group.arn
  }
}
