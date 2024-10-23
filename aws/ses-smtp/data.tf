data "aws_route53_zone" "selected" {
  name         = var.domain
  private_zone = var.private_zone
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnets" "selected" {

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  filter {
    name   = "tag:Name"
    values = ["filtered*"]
  }
}

data "aws_subnet" "selected" {
  count = length(data.aws_subnets.selected.ids)
  id    = data.aws_subnets.selected.ids[count.index]
}

data "aws_region" "current" {}

locals {
  subnets          = data.aws_subnet.selected
  endpoint_subnets = var.ses_endpoint_failover ? slice(local.subnets, 0, 2) : [local.subnets[0]]
}
