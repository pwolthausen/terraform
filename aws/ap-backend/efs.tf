resource "aws_security_group" "web_efs_security_group" {
  name        = "${var.name}-${var.environment}-web-efs"
  description = "Web efs for ${var.name} in ${var.environment} Security Group"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description     = "Allow Web Server to mount EFS over network"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [data.aws_security_group.tmp_allow_ssh_sg.id, var.web_server_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.name}-${var.environment}-web-efs-sg"
    Environment = var.environment
  }
}

resource "aws_kms_key" "efs_storage_kms_key" {
  description = "Key used to encrypt the EFS storage"
}

resource "aws_kms_alias" "efs_storage_kms_key_alias" {
  name          = "alias/efs-storage-${var.name}-${var.environment}"
  target_key_id = aws_kms_key.efs_storage_kms_key.key_id
}

resource "aws_efs_file_system" "efs_storage" {
  creation_token   = "efs-${var.name}-${var.environment}"
  performance_mode = lookup(var.efs_storage, "performance_mode")
  throughput_mode  = lookup(var.efs_storage, "throughput_mode")
  encrypted        = true
  kms_key_id       = aws_kms_key.efs_storage_kms_key.arn

  tags = {
    Name        = var.name
    Environment = var.environment
  }
}

resource "aws_efs_mount_target" "efs_storage_mt" {
  count           = length(var.availability_zones)
  file_system_id  = aws_efs_file_system.efs_storage.id
  subnet_id       = tolist(data.aws_subnet_ids.paas_subnet.ids)[count.index]
  security_groups = [aws_security_group.web_efs_security_group.id]
}
