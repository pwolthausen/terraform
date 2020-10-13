resource "google_compute_project_metadata" "rke_ssh_keys" {
  metadata = {
    ssh-keys = "rke-user:${var.ssh_key}"
  }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#Cluster nodes
resource "google_compute_instance" "master" {
  count        = 3
  name         = format("%s-master-%02d", var.cluster_name, count.index + 1)
  zone         = element(var.zones, count.index)
  machine_type = var.master_machine_type
  tags         = ["master"]

  allow_stopping_for_update = true

  boot_disk {
    source = google_compute_disk.master[count.index].self_link
  }
  network_interface {
    network    = var.network
    subnetwork = var.subnet
    access_config {}
  }
  service_account {
    scopes = ["logging-write"]
  }
}
resource "google_compute_disk" "master" {
  count = 3
  name  = format("%s-master-%02d", var.cluster_name, count.index + 1)
  zone  = element(var.zones, count.index)
  image = var.image
  size  = var.master_disk_size
  type  = "pd-standard"
}

resource "google_compute_instance" "worker" {
  count        = var.worker_count
  name         = format("%s-worker-%02d", var.cluster_name, count.index + 1)
  zone         = element(var.zones, count.index)
  machine_type = var.worker_machine_type
  tags         = ["worker"]

  allow_stopping_for_update = true

  boot_disk {
    source = google_compute_disk.worker[count.index].self_link
  }
  network_interface {
    network    = var.network
    subnetwork = var.subnet
    access_config {}
  }
  service_account {
    scopes = ["logging-write"]
  }
}
resource "google_compute_disk" "worker" {
  count = 3
  name  = format("%s-worker-%02d", var.cluster_name, count.index + 1)
  zone  = element(var.zones, count.index)
  image = var.image
  size  = var.worker_disk_size
  type  = "pd-standard"
}

resource "google_compute_instance" "worker_st" {
  count        = var.worker_st_count
  name         = format("%s-worker-st-%02d", var.cluster_name, count.index + 1)
  zone         = element(var.zones, count.index)
  machine_type = var.worker_st_machine_type
  tags         = ["worker"]

  allow_stopping_for_update = true

  boot_disk {
    source = google_compute_disk.worker_st[count.index].self_link
  }
  attached_disk {
    source = google_compute_disk.worker_st_data[count.index].self_link
  }
  network_interface {
    network    = var.network
    subnetwork = var.subnet
    access_config {}
  }
  service_account {
    scopes = ["logging-write"]
  }
}
resource "google_compute_disk" "worker_st" {
  count = var.worker_st_count
  name  = format("%s-worker-st-%02d", var.cluster_name, count.index + 1)
  zone  = element(var.zones, count.index)
  image = var.image
  size  = var.worker_st_disk_size
  type  = "pd-standard"
}
resource "google_compute_disk" "worker_st_data" {
  count = var.worker_st_count
  name  = format("%s-worker-st-%02d", var.cluster_name, count.index + 1)
  zone  = element(var.zones, count.index)
  image = var.image
  size  = var.worker_st_data_disk_size
  type  = "pd-standard"
}
