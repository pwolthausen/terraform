data aws_vpc vpc {
  filter {
    name   = "tag:Environment"
    values = ["${var.environment}"]
  }
}

data aws_security_group tmp_allow_ssh_sg {
  filter {
    name   = "tag:Name"
    values = ["temp-allow-ssh"]
  }
}

data aws_security_group bastion_security_group {
  filter {
    name   = "tag:Name"
    values = ["${var.environment}-bastion"]
  }
}

data aws_subnet_ids paas_subnet {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Usage"
    values = ["AWS PaaS"]
  }
}

