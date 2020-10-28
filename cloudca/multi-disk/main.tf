provider "cloudca" {
  api_key = var.api_key
  api_url = "https://api.cloud.ca/v1"
}

data "template_file" "cloudinit_cmc" {
  template = "${file("./cloudini.tpl")}"
}

resource "cloudca_instance" "cmc" {
  count = var.cmc_count

  name           = format("test-cloudinit-%02d", count.index + 1)
  environment_id = var.envID
  network_id     = var.netID
  template       = var.template

  compute_offering       = "Standard"
  cpu_count              = 2
  memory_in_mb           = 4096
  root_volume_size_in_gb = 10

  ssh_key_name = var.ssh_key_name
  user_data    = data.template_file.cloudinit_cmc.rendered
}
resource "cloudca_volume" "cmc_var_log" {
  count = var.cmc_count

  name           = format("data-logs-%02d", count.index + 1)
  environment_id = var.envID

  instance_id   = cloudca_instance.cmc[count.index].id
  disk_offering = "Guaranteed Performance, 5000 iops min"
  size_in_gb    = 15
}
resource "cloudca_volume" "cmc_home" {
  count = var.cmc_count

  name           = format("data-home-%02d", count.index + 1)
  environment_id = var.envID

  instance_id   = cloudca_instance.cmc[count.index].id
  disk_offering = "Guaranteed Performance, 5000 iops min"
  size_in_gb    = 10

  depends_on = [cloudca_volume.cmc_var_log]
}
resource "cloudca_volume" "cmc_data" {
  count = var.cmc_count

  name           = format("data-%02d", count.index + 1)
  environment_id = var.envID

  instance_id   = cloudca_instance.cmc[count.index].id
  disk_offering = "Guaranteed Performance, 5000 iops min"
  size_in_gb    = 20

  depends_on = [cloudca_volume.cmc_home]
}

resource "cloudca_port_forwarding_rule" "cmc" {
  count              = var.cmc_count
  environment_id     = var.envID
  public_ip_id       = cloudca_public_ip.nat_ip.id
  public_port_start  = 22 + count.index
  private_ip_id      = cloudca_instance.cmc[count.index].private_ip_id
  private_port_start = 22
  protocol           = "TCP"
}
resource "cloudca_public_ip" "nat_ip" {
  environment_id = var.envID
  vpc_id         = var.vpcID
}

output "ssh_ip" {
  value = cloudca_public_ip.nat_ip.ip_address
}
output "user-data" {
  value = cloudca_instance.cmc.*.user_data
}
