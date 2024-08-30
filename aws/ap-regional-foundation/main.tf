resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/21"
  # enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = true
  tags = {
    Environment = var.environment
  }
}
######################
### Public subnets ###
######################
resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Environment = var.environment
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public.id
  }
  tags = {
    Environment = var.environment
  }
  lifecycle {
    ignore_changes = [route]
  }
}
resource "aws_subnet" "public_subnets" {
  count                   = length(var.availability_zones)
  availability_zone       = var.availability_zones[count.index]
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 3, count.index + (2 * length(var.availability_zones)))
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.vpc.id
  tags = {
    Environment = var.environment
    Usage       = "Public"
    Zone        = var.availability_zones[count.index]
  }
}
resource "aws_route_table_association" "internet" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.internet.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

#######################
### Private subnets ###
#######################
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "${var.environment}-nat-ip"
  }
}
resource "aws_nat_gateway" "private" {
  subnet_id     = aws_subnet.internet[0].id
  allocation_id = aws_eip.nat.id
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.private.id
  }
  tags = {
    Environment = var.environment
    Name        = var.environment
  }
  lifecycle {
    ignore_changes = [route]
  }
}
resource "aws_subnet" "private_subnets" {
  count                   = length(var.availability_zones)
  availability_zone       = var.availability_zones[count.index]
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 3, count.index)
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.vpc.id
  tags = {
    Environment = var.environment
    Usage       = "Private"
    Zone        = var.availability_zones[count.index]
  }
}
resource "aws_route_table_association" "web_route_table_association" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

####################################################
### Subnets for AWS PaaS services (rds, EFS, S3) ###
####################################################
resource "aws_subnet" "services_subnets" {
  count                   = length(var.availability_zones)
  availability_zone       = var.availability_zones[count.index]
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 3, count.index + length(var.availability_zones))
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.vpc.id
  tags = {
    Environment = var.environment
    Usage       = "AWS PaaS"
    Zone        = var.availability_zones[count.index]
  }
}

###############
### Bastion ###
###############
resource "aws_security_group" "bastion" {
  name        = "${var.environment}-bastion"
  description = "Security Group for ${var.environment} Bastion"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.access_ips
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "${var.environment}-bastion"
    Environment = var.environment
  }
}

data "aws_ami" "hardened_bastion" {
  owners = [aws_vpc.vpc.owner_id]
  filter {
    name   = "name"
    values = ["hardened-bastion"]
  }
}

resource "aws_kms_key" "bastion_root_disk" {
  description = "KMS key for encrypting root disk for bastion"
}
resource "aws_kms_alias" "bastion" {
  name          = "alias/${var.environment}-bastion"
  target_key_id = aws_kms_key.bastion_root_disk.key_id
}

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.hardened_bastion.id
  instance_type = "t2.nano"
  tags = {
    environment = var.environment
    role        = "bastion"
    Name        = "bastion-${var.region}-${var.environment}"
  }
  vpc_security_group_ids = [aws_security_group.bastion.id]
  subnet_id              = aws_subnet.internet[1].id

  root_block_device {
    encrypted   = true
    kms_key_id  = aws_kms_key.bastion_root_disk.arn
    volume_size = 30
  }
}

###############################################
### SG for webserver configuration pipeline ###
###############################################
resource "aws_security_group" "temp_allow_ssh" {
  name        = "temp-allow-ssh"
  description = "Allows SSH access to temporary host for webserver config"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "temp-allow-ssh"
    Environment = var.environment
  }
}
