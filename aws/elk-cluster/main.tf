provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

data "aws_ami" "elk_nodes" {
  owners = "${var.ami_owners}"

  filter {
    name   = "name"
    values = ["${var.elk_ami}"]
  }
}

resource "aws_key_pair" "elk" {
  key_name   = "elk"
  public_key = "${var.elk_pub_ssh}"
}

resource "aws_security_group" "elk-cluster" {
  name        = "elk-cluster"
  description = "Security group for nodes in the ELK cluster"
  vpc_id      = "${var.vpc_id}"

  ingress {
    description     = "Rule to allow SSH from the bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${var.bastion_security_group}"]
  }

  ingress {
    description = "Allow all traffic between ELK nodes"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "elastic" {
  name        = "elastic-nodes"
  description = "Security group for data nodes in the ELK cluster"
  vpc_id      = "${var.vpc_id}"

  ingress {
    description     = "rule to allow hosts in the VPC to send logs to elk"
    from_port       = 9200
    to_port         = 9200
    protocol        = "tcp"
    security_groups = ["${var.all_security_group}"]
  }

  ingress {
    description     = "rule to allow hosts in the VPC to send logs to elk"
    from_port       = 9300
    to_port         = 9300
    protocol        = "tcp"
    security_groups = ["${var.all_security_group}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "kibana" {
  name        = "kibana"
  description = "Allow access to Kibana from the Bastion"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${var.bastion_security_group}"]
  }

  ingress {
    from_port       = 5601
    to_port         = 5601
    protocol        = "tcp"
    security_groups = ["${var.bastion_security_group}"]
  }

  # ##Enable this rule if APM is being run on the kibana server
  # ingress {
  #   description     = "rule to allow hosts in the VPC to send beats to apm"
  #   from_port       = 5040
  #   to_port         = 5060
  #   protocol        = "tcp"
  #   security_groups = ["${var.all_security_group}"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
