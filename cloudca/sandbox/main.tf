######################################################
###########       Create the Network       ###########
######################################################

resource "cloudca_vpc" "vpc" {
  environment_id = var.environment_id
  name           = "sandbox-default-vpc"
  description    = "Default VPC"
  vpc_offering   = "Default VPC offering"
}

resource "cloudca_network_acl" "sandbox_acl" {
  environment_id = var.environment_id
  name           = "sandbox-acl"
  description    = "Default ACL for the sandbox network"
  vpc_id         = cloudca_vpc.vpc.id
}

resource "cloudca_network_acl_rule" "sandbox_acl_allow_internal" {
  environment_id = var.environment_id
  rule_number    = 100
  cidr           = "10.0.0.0/8"
  action         = "Allow"
  protocol       = "TCP"
  start_port     = 1
  end_port       = 65000
  traffic_type   = "Ingress"
  network_acl_id = cloudca_network_acl.sandbox_acl.id
}

resource "cloudca_network_acl_rule" "sandbox_acl_allow_ssh" {
  environment_id = var.environment_id
  rule_number    = 101
  cidr           = "173.178.40.19/32"
  action         = "Allow"
  protocol       = "TCP"
  start_port     = 22
  end_port       = 22
  traffic_type   = "Ingress"
  network_acl_id = cloudca_network_acl.sandbox_acl.id
}

resource "cloudca_network" "network" {
  environment_id   = var.environment_id
  description      = "Basic network for use in sandbox"
  name             = "sandbox-network"
  vpc_id           = cloudca_vpc.vpc.id
  network_offering = "Load Balanced Tier"
  network_acl      = cloudca_network_acl.sandbox_acl.id
}

####################################################
###########    Create static resources    ##########
####################################################

resource "cloudca_ssh_key" "sandbox_default" {
  environment_id = var.environment_id
  name           = "sandbox-default"
  public_key     = var.public_key
}

####################################################
###########   Create dynamic resources   ###########
####################################################

resource "cloudca_public_ip" "nat_ip" {
  environment_id = var.environment_id
  vpc_id         = cloudca_vpc.vpc.id
}

resource "cloudca_port_forwarding_rule" "replicated_test_allow_ssh_leader" {
  environment_id     = var.environment_id
  public_ip_id       = cloudca_public_ip.nat_ip.id
  public_port_start  = 22
  private_ip_id      = cloudca_instance.bastion.private_ip_id
  private_port_start = 22
  protocol           = "TCP"
}

resource "cloudca_instance" "bastion" {
  environment_id         = var.environment_id
  name                   = "bastion"
  network_id             = cloudca_network.network.id
  template               = "97a20c63-6aad-4565-a7cc-e95bb16f5485"
  compute_offering       = "Standard"
  cpu_count              = 2
  memory_in_mb           = 4096
  ssh_key_name           = "sandbox-default"
  root_volume_size_in_gb = 100
  private_ip             = cidrhost(cloudca_network.network.cidr, 10)
  # user_data              = templatefile("cloud-init.yaml", { public_key = var.public_key, passwd = base64sha256(var.password) })
}
