resource "aws_instance" "kibana" {
  ami               = "${data.aws_ami.elk_nodes.id}"
  instance_type     = "${var.kibana_machine_size}"
  availability_zone = "${var.zone}"

  tags = {
    Name        = "elk-kibana"
    role        = "elk-kibana"
    environment = "prod"
  }

  disable_api_termination = "${var.protection}"
  key_name                = "${aws_key_pair.elk.key_name}"

  ##Security groups must be commented out to allow running future updates
  # security_groups = ["${aws_security_group.elk-cluster.id}", "${aws_security_group.kibana.id}"]
  subnet_id = "${var.subnet_id}"

  private_ip = "${var.serviceip[0]}"

  root_block_device {
    volume_size = "${var.kibana_disk_size}"
  }
}

###Uncomment this block to spin up a separate APM server
###Block can be repeated to add additional nodes such as logstash
# resource "aws_instance" "apm" {
#   ami               = "${data.aws_ami.elk_nodes.id}"
#   instance_type     = "${var.apm_machine_size}"
#   availability_zone = "${var.zone}"
#
#   tags = {
#     Name        = "elk-apm"
#     role        = "elk-apm"
#     environment = "prod"
#   }
#
#   disable_api_termination = "${var.protection}"
#   key_name                = "${aws_key_pair.elk.key_name}"
#
#   ##Security groups must be commented out to allow running future updates
#   security_groups             = ["${aws_security_group.elk-cluster.id}", "${aws_security_group.apm.id}"]
#   subnet_id                   = "${var.subnet_id}"
#   private_ip                  = "${var.serviceip[1]}"
#
#   root_block_device {
#     volume_size = "${var.apm_disk_size}"
#   }
# }
#
# resource "aws_security_group" "apm" {
#   name        = "apm"
#   description = "Open port for APM"
#   vpc_id      = "${var.vpc_id}"
#
#   ingress {
#     description     = "rule to allow hosts in the VPC to send beats to apm"
#     from_port       = 5040
#     to_port         = 5050
#     protocol        = "tcp"
#     security_groups = ["${var.all_security_group}"]
#   }
#
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
