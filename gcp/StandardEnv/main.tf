## Add project wide public SSH keys. Default will add automation ssh key and client admin key. Other client keys can be added if provided.
resource "google_compute_project_metadata" "default" {
  metadata = {
    ssh-keys = "automation:${var.automation_key}\nadmin:${var.client_admin_key}"
  }
}

module "mig_http" {
  source = "../modules/mig-http"
}
  
module "glb" {
  source = "../modules/glb"

  name   = var.name
  group  = module.mig_http.group
  hcpath = var.hcpath
}

module "backend" {
  source = "../modules/backend"
}