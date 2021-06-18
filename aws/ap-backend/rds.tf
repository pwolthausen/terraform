resource "aws_security_group" "mod" {
  name        = "${var.name}-${var.environment}-db"
  description = "Allow Aurora DB traffic"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.web_server_sg_id, data.aws_security_group.bastion_security_group.id, data.aws_security_group.tmp_allow_ssh_sg.id]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [var.web_server_sg_id, data.aws_security_group.bastion_security_group.id]
  }
  tags = {
    Name        = "${var.name}-${var.environment}-rds-sg"
    Environment = var.environment
  }
}

resource "aws_db_subnet_group" "mod" {
  name        = "${var.name}-${var.environment}"
  description = "Primary db subnet"
  subnet_ids  = tolist(data.aws_subnet_ids.paas_subnet.ids)
}

resource "aws_kms_key" "rds" {
  description = "KMS key for encrypting RDS"
}
resource "aws_kms_alias" "rds" {
  name          = "alias/${var.name}-${var.environment}-rds"
  target_key_id = aws_kms_key.rds.key_id
}


resource "aws_rds_cluster" "mod" {
  cluster_identifier = "${var.name}-${var.environment}"
  availability_zones = var.availability_zones

  engine         = "aurora"
  engine_mode    = "serverless"
  engine_version = var.aurora_db.engine_version

  database_name                   = "${replace(var.name, "-", "_")}_${var.environment}"
  master_username                 = var.aurora_db.master_username
  master_password                 = var.aurora_db.master_password
  skip_final_snapshot             = true
  backup_retention_period         = var.backup_retention_period
  snapshot_identifier             = var.snapshot_identifier
  storage_encrypted               = true
  kms_key_id                      = aws_kms_key.rds.arn
  apply_immediately               = var.apply_immediately
  db_subnet_group_name            = aws_db_subnet_group.mod.name
  vpc_security_group_ids          = [aws_security_group.mod.id]
  db_cluster_parameter_group_name = var.aurora_db.db_cluster_parameter_group_name

  scaling_configuration {
    auto_pause   = false
    max_capacity = var.aurora_db.max_capacity
    min_capacity = var.aurora_db.min_capacity
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      availability_zones
    ]
  }
  tags = {
    Environment = var.environment
    Name        = var.name
  }
}
