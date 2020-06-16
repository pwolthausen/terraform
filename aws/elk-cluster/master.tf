resource "aws_instance" "elk_master" {
  count             = 3
  ami               = "${data.aws_ami.elk_nodes.id}"
  instance_type     = "${var.master_machine_size}"
  availability_zone = "${var.zone}"

  tags = {
    Name        = "${format("elk-Master-%01d", count.index + 1)}"
    role        = "elk-master"
    environment = "prod"
  }

  disable_api_termination = "${var.protection}"
  key_name                = "${aws_key_pair.elk.key_name}"

  ##Security groups must be commented out to allow running future updates
  # security_groups = ["${aws_security_group.elk-cluster.id}", "${aws_security_group.elastic.id}"]
  subnet_id = "${var.subnet_id}"

  private_ip = "${var.masterip[count.index]}"

  root_block_device {
    volume_size = "16"
  }
}

resource "aws_volume_attachment" "master-data-disks" {
  count       = 3
  device_name = "${var.data_dir}"
  volume_id   = "${element(aws_ebs_volume.elk_master.*.id, count.index)}"
  instance_id = "${element(aws_instance.elk_master.*.id, count.index)}"
}

resource "aws_ebs_volume" "elk_master" {
  count             = 3
  availability_zone = "${var.zone}"
  size              = "${var.master_data_disk_size}"

  tags = {
    Name = "${format("elk-data-hot-data-%01d", count.index + 1)}"
  }
}
