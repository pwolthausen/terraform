resource "aws_instance" "elk_hot" {
  count             = 2
  ami               = "${data.aws_ami.elk_nodes.id}"
  instance_type     = "${var.hotdata_machine_size}"
  availability_zone = "${var.zone}"

  tags = {
    Name        = "${format("elk-data-hot-%01d", count.index + 1)}"
    role        = "elk-data-hot"
    environment = "prod"
  }

  disable_api_termination = "${var.protection}"
  key_name                = "${aws_key_pair.elk.key_name}"

  ##Security groups must be commented out to allow running future updates
  # security_groups = ["${aws_security_group.elk-cluster.id}", "${aws_security_group.elastic.id}"]
  subnet_id = "${var.subnet_id}"

  private_ip = "${var.datahotip[count.index]}"

  root_block_device {
    volume_size = "16"
  }
}

resource "aws_volume_attachment" "hot-data-disks" {
  count       = 2
  device_name = "${var.data_dir}"
  volume_id   = "${element(aws_ebs_volume.elk_hot.*.id, count.index)}"
  instance_id = "${element(aws_instance.elk_hot.*.id, count.index)}"
}

resource "aws_ebs_volume" "elk_hot" {
  count             = 2
  availability_zone = "${var.zone}"
  size              = "${var.hotdata_data_disk_size}"

  tags = {
    Name = "${format("elk-data-hot-data-%01d", count.index + 1)}"
  }
}
