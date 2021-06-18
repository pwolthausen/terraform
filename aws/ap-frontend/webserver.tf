resource "aws_security_group" "web_server_security_group" {
  name        = "${var.name}-${var.environment}-web-server"
  description = "Web server for ${var.name} in ${var.environment} Security Group"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg]
  }
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [data.aws_security_group.bastion_security_group.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "${var.name}-${var.environment}-webserver-sg"
    Environment = var.environment
  }
}
resource "aws_kms_key" "webserver" {
  description = "KMS key for encrypting root disk for bastion"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Sid" : "Enable IAM User Permissions",
      "Effect" : "Allow",
      "Principal" : {
        "AWS" : "arn:aws:iam::${aws_security_group.web_server_security_group.owner_id}:root"
      },
      "Action" : "kms:*",
      "Resource" : "*"
      },
      {
        "Sid" : "Allow service-linked role use of the CMK",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${aws_security_group.web_server_security_group.owner_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
          ]
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "Allow attachment of persistent resources",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${aws_security_group.web_server_security_group.owner_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
          ]
        },
        "Action" : [
          "kms:CreateGrant"
        ],
        "Resource" : "*",
        "Condition" : {
          "Bool" : {
            "kms:GrantIsForAWSResource" : true
          }
        }
      }
    ]
  })
}
resource "aws_kms_alias" "webserver" {
  name          = "alias/${var.name}-${var.environment}-webservers"
  target_key_id = aws_kms_key.webserver.key_id
}

resource "aws_launch_template" "web_server_template" {
  name_prefix   = "${var.name}-${var.environment}-template"
  description   = "Template for ${var.name} in ${var.environment}"
  image_id      = data.aws_ami.golden_image.id
  instance_type = var.web_server.instance_type

  vpc_security_group_ids = [aws_security_group.web_server_security_group.id]

  lifecycle {
    create_before_destroy = true
  }
  monitoring {
    enabled = true
  }
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = var.web_server.disk_size
      encrypted   = true
      kms_key_id  = aws_kms_key.webserver.arn
    }
  }
  tags = {
    environment = var.environment
    prefix      = "${var.name}-${var.environment}-web-server"
    Name        = "${var.name}-${var.environment}"
    role        = "webserver"
  }
}

resource "aws_autoscaling_group" "web_server_autoscaling" {
  count = length(data.aws_subnet_ids.private_subnet.ids)

  name_prefix               = "${var.name}-${var.environment}-web-server-scalinggroup"
  vpc_zone_identifier       = [tolist(data.aws_subnet_ids.private_subnet.ids)[count.index]]
  max_size                  = var.max_size
  min_size                  = var.min_size
  target_group_arns         = [aws_lb_target_group.web_server_target_group.arn]
  health_check_grace_period = 300
  health_check_type         = "EC2"

  launch_template {
    id      = aws_launch_template.web_server_template.id
    version = "$Latest"
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = [{
    "key"                 = "environment"
    "value"               = var.environment
    "propagate_at_launch" = true
    }, {
    "key"                 = "Prefix"
    "value"               = "${var.environment}-web-server-scalinggroup"
    "propagate_at_launch" = true
    }, {
    "key"                 = "Name"
    "value"               = "${var.name}-${var.environment}-webserver-${count.index}"
    "propagate_at_launch" = true
    }, {
    "key"                 = "role"
    "value"               = "webserver"
    "propagate_at_launch" = true
  }]
}
