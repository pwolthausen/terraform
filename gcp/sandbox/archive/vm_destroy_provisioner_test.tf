# //Resource will create VMs depending to the VM variable(count, machine type etc.)
#
# resource "google_compute_disk" "default" {
#   project = var.project_id
#   name    = "${var.name}-boot-disk"
#   zone    = "${var.region}-c"
#   type    = "pd-standard"
#   size    = 50
#   image   = var.image
#   labels  = merge(var.labels, { disk = "boot_disk" })
#
#   lifecycle {
#     ignore_changes = []
#   }
# }
#
# resource "google_compute_instance" "default" {
#   project      = var.project_id
#   name         = var.name
#   machine_type = var.machine_type
#   zone         = "${var.region}-c"
#
#   tags     = ["cart-test"]
#   labels   = var.labels
#   hostname = "${each.key}.${var.ac_domain}"
#
# #   allow_stopping_for_update = var.allow_stopping_for_update
#
#   boot_disk {
#     source = google_compute_disk.default.self_link
#   }
#   network_interface {
#     network    = data.google_compute_network.cartdotcom.name
#     network_ip = google_compute_address.internal_static.address
#     subnetwork = data.google_compute_subnetwork.prod.self_link
#     dynamic "access_config" {
#       for_each = toset(google_compute_address.external_static)
#       content {
#         nat_ip       = access_config.value.address
#         network_tier = "PREMIUM"
#       }
#     }
#   }
#
#   scheduling {
#     on_host_maintenance = "MIGRATE"
#   }
#
# #   service_account {
# #     email  = var.sa
# #     scopes = ["cloud-platform"]
# #   }
#
# #   metadata = {
# #     windows-startup-script-ps1    = var.startup_ps1
# #     sysprep-specialize-script-ps1 = var.sysprep_ps1
# #     windows-startup-script-cmd    = var.startup_cmd
# #   }
#
#   provisioner "local-exec" {
#     command = ["Remove-ADComputer -Credentials -Server ${self.hostname}"]
#     interpreter = ["powershell"]
#     when = destroy
#     on_failure = continue
#   }
# }
#
# resource "null_resource" "managed_ad_join" {
#   provisioner "local-exec" {
#     command = "yes | gcloud --project ${var.project_id} compute instances list"
#   }
#   triggers = {
#     version = google_sql_database_instance.app_db[count.index].settings[0].version
#   }
# }
#
#
# resource "google_compute_address" "external_static" {
#   project = var.project_id
#   region  = var.region
#
#   name         = "${var.name}-ext-ip"
#   address_type = "EXTERNAL"
# }
#
# resource "google_compute_address" "internal_static" {
#   project = var.project_id
#   region  = var.region
#
#   name         = "${var.name}-int-ip"
#   subnetwork   = data.google_compute_subnetwork.prod.self_link
#   address_type = "INTERNAL"
#   address      = cidrhost(data.google_compute_subnetwork.prod.ip_cidr_range, 16)
# }
