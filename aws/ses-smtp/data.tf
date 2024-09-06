data "aws_route53_zone" "selected" {
  name = var.domain
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnets" "selected" {

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_subnet" "selected" {
  count = length(data.aws_subnets.selected.ids)
  id    = data.aws_subnets.selected.ids[count.index]
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  subnets            = data.aws_subnet.selected
  endpoint_subnets   = var.ses_endpoint_failover ? slice(local.subnets, 0, 2) : [local.subnets[0]]
  availability_zones = data.aws_availability_zones.available.names
}
