resource "cloudca_instance" "leader" {
  count = var.leader.count

  environment_id = var.environment_id
  network_id     = var.leader.network_id

  name         = format("%s-leader-%02d", var.cluster_name, count.index + 1)
  template     = var.image

  compute_offering       = "Standard"
  cpu_count              = var.leader.cpu
  memory_in_mb           = var.leader.memory
  root_volume_size_in_gb = 30

#  private_ip = var.leader_ip_addresses[count.index]
  private_ip = cidrhost(var.leader.ip_range, var.leader.host + count.index)
  user_data  = file("${path.module}/cloud-init")
}
resource "cloudca_volume" "leader_docker" {
  count = var.leader.count

  environment_id = var.environment_id
  instance_id    = element(cloudca_instance.leader.*.id, count.index)

  name          = format("%s-leader-docker-%02d", var.cluster_name, count.index + 1)
  disk_offering = var.leader.disk_offering
  size_in_gb    = var.leader.docker_disk
}

resource "cloudca_instance" "worker" {
  count = var.worker.count

  environment_id = var.environment_id
  network_id     = var.worker.network_id

  name         = format("%s-worker-%02d", var.cluster_name, count.index + 1)
  template     = var.image

  compute_offering       = "Standard"
  cpu_count              = var.worker.cpu
  memory_in_mb           = var.worker.memory
  root_volume_size_in_gb = 30

#  private_ip = var.worker_ip_addresses[count.index]
  private_ip = cidrhost(var.worker.ip_range, var.worker.host + count.index)
  user_data  = file("${path.module}/cloud-init")
}
resource "cloudca_volume" "worker_docker" {
  count = var.worker.count

  environment_id = var.environment_id
  instance_id    = element(cloudca_instance.worker.*.id, count.index)

  name          = format("%s-worker-docker-%02d", var.cluster_name, count.index + 1)
  disk_offering = var.worker.disk_offering
  size_in_gb    = var.worker.docker_disk
}

resource "cloudca_instance" "worker_st" {
  count = var.worker_st.count

  environment_id = var.environment_id
  network_id     = var.worker_st.network_id

  name         = format("%s-worker-st-%02d", var.cluster_name, count.index + 1)
  template     = var.image

  compute_offering       = "Standard"
  cpu_count              = var.worker_st.cpu
  memory_in_mb           = var.worker_st.memory
  root_volume_size_in_gb = 30

#  private_ip = var.worker_st_ip_addresses[count.index]
  private_ip = cidrhost(var.worker_st.ip_range, var.worker_st.host + count.index)
  user_data  = file("${path.module}/cloud-init")
}
resource "cloudca_volume" "worker_st_docker" {
  count = var.worker_st.count

  environment_id = var.environment_id
  instance_id    = element(cloudca_instance.worker_st.*.id, count.index)

  name          = format("%s-worker-st-docker-%02d", var.cluster_name, count.index + 1)
  disk_offering = var.worker_st.disk_offering
  size_in_gb    = var.worker_st.docker_disk
}
resource "cloudca_volume" "worker_st_data" {
  count = var.worker_st.count

  environment_id = var.environment_id
  instance_id    = element(cloudca_instance.worker_st.*.id, count.index)

  name          = format("%s-worker-st-data-%02d", var.cluster_name, count.index + 1)
  disk_offering = var.worker_st.data_disk_offering
  size_in_gb    = var.worker_st.data_size
  
  depends_on = [
    cloudca_volume.worker_st_docker,
  ]
}
