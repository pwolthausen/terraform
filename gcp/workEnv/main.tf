##Set provider config
provider "google" {
  project = var.project_id
}

resource "google_compute_address" "bastion_ip" {
  name   = "bastion-ip"
  region = var.region
}

output "bastion_ip" {
  value = google_compute_address.bastion_ip.address
}

resource "google_compute_instance" "bastionHost" {
  name         = "bastion"
  zone         = "${var.region}-a"
  machine_type = "f1-micro"
  tags         = ["bastion"]

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      size  = "30"
      type  = "pd-standard"
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = module.core_network.network_self_link
    subnetwork = module.core_network.subnets["${var.region}/dublin"].self_link

    access_config {
      nat_ip = google_compute_address.bastion_ip.address
    }
  }

  metadata = {
    block-project-ssh-keys = "true"
    enable-oslogin         = "true"
  }

  service_account {
    scopes = []
  }
}

# module "gke_sheehy" {
#   source  = "terraform-google-modules/kubernetes-engine/google"
#   version = "23.1.0"
#
#   project_id = var.project_id
#   region     = var.region
#   name       = "sheehy"
#
#
#   network                    = module.core_network.network_self_link
#   subnetwork                 = module.core_network.subnets["dublin"]
#   ip_range_pods              = module.core_network.subnets_secondary_ranges
#   ip_range_services          = module.core_network.subnets_secondary_ranges
#   add_cluster_firewall_rules = true
#   master_authorized_networks = [
#     {
#       cidr_block   = "${var.my_ip}/32"
#       display_name = "my_pc"
#     }
#   ]
#
#   enable_vertical_pod_autoscaling = true
#   filestore_csi_driver            = true
#   grant_registry_access           = true
#   remove_default_node_pool        = true
#
#   node_pools = [
#     {
#       name         = "narwhal"
#       machine_type = "e2-medium"
#       min_count    = 1
#       max_count    = 3
#       image_type   = "COS_CONTAINERD"
#       enable_gcfs  = true
#     },
#     {
#       name         = "kube-system"
#       machine_type = "e2-medium"
#       min_count    = 1
#       max_count    = 1
#       image_type   = "COS_CONTAINERD"
#     }
#   ]
#
#   node_pools_taints = {
#     narwhal = [
#       {
#         key    = "app"
#         value  = "user"
#         effect = "NO_SCHEDULE"
#       }
#     ]
#   }
# }
