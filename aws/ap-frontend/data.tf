data "aws_route53_zone" "hosted_zone" {
  name = var.host_zone
}
data aws_vpc vpc {
  filter {
    name = "tag:Environment"
    values = ["${var.environment}"]
  }
}

data aws_subnet_ids public_subnet {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Usage"
    values = ["Public"]
  }
}

data aws_subnet_ids private_subnet {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Usage"
    values = ["Private"]
  }
}

data aws_security_group bastion_security_group {
  filter {
    name   = "tag:Name"
    values = ["${var.environment}-bastion"]
  }
}

data "aws_ami" "golden_image" {
  owners      = [aws_security_group.web_server_security_group.owner_id]
  most_recent = true
  
  filter {
    name   = "name"
    values = ["golden-image-${var.name}*"]
  }
  
  filter {
    name   = "tag:app_release"
    values = [var.web_server.release]
  }
}