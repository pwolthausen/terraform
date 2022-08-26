#=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=
# ELK master nodes

resource "cloudca_instance" "elk_master" {
  count = var.masters

  name           = format("%s-master-%02d", var.cluster_name, count.index + 1)
  environment_id = var.environment_id
  network_id     = var.network_id
  template       = var.cca_image

  compute_offering       = "Standard"
  cpu_count              = var.master_cpu
  memory_in_mb           = var.master_memory
  root_volume_size_in_gb = 40

  private_ip   = format("%s.20%d", var.network_cidr, count.index + 2)
  ssh_key_name = var.automation_key
}
resource "cloudca_volume" "elk_master_data" {
  count = var.masters

  name           = format("%s-master-data%02d", var.cluster_name, count.index + 1)
  environment_id = var.environment_id

  instance_id   = cloudca_instance.elk_master[count.index].id
  disk_offering = var.disk_offering
  size_in_gb    = var.master_data_disk
}

#=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=
# ELK hot data nodes

resource "cloudca_instance" "elk_hot" {
  count = var.data_hot

  name           = format("%s-hot-%02d", var.cluster_name, count.index + 1)
  environment_id = var.environment_id
  network_id     = var.network_id
  template       = var.cca_image

  compute_offering       = "Standard"
  cpu_count              = var.data_hot_cpu
  memory_in_mb           = var.data_hot_memory
  root_volume_size_in_gb = 40

  private_ip   = format("%s.21%d", var.network_cidr, count.index)
  ssh_key_name = var.automation_key
}

resource "cloudca_volume" "elk_hot_data" {
  count = var.data_hot

  name           = format("%s-hot-data%02d", var.cluster_name, count.index + 1)
  environment_id = var.environment_id

  instance_id   = cloudca_instance.elk_hot[count.index].id
  disk_offering = var.disk_offering
  size_in_gb    = var.data_hot_data_disk
}

#=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=
# ELK warm data nodes

resource "cloudca_instance" "elk_warm" {
  count = var.data_warm

  name           = format("%s-warm-%02d", var.cluster_name, count.index + 1)
  environment_id = var.environment_id
  network_id     = var.network_id
  template       = var.cca_image

  compute_offering       = "Standard"
  cpu_count              = var.data_warm_cpu
  memory_in_mb           = var.data_warm_memory
  root_volume_size_in_gb = 40

  private_ip   = format("%s.22%d", var.network_cidr, count.index)
  ssh_key_name = var.automation_key
}

resource "cloudca_volume" "elk_warm_data" {
  count = var.data_warm

  name           = format("%s-warm-data%02d", var.cluster_name, count.index + 1)
  environment_id = var.environment_id

  instance_id   = cloudca_instance.elk_warm[count.index].id
  disk_offering = var.disk_offering
  size_in_gb    = var.data_warm_data_disk
}

#=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=
# ELK cold data nodes

resource "cloudca_instance" "elk_cold" {
  count = var.data_cold

  name           = format("%s-cold-%02d", var.cluster_name, count.index + 1)
  environment_id = var.environment_id
  network_id     = var.network_id
  template       = var.cca_image

  compute_offering       = "Standard"
  cpu_count              = var.data_cold_cpu
  memory_in_mb           = var.data_cold_memory
  root_volume_size_in_gb = 40

  private_ip   = format("%s.23%d", var.network_cidr, count.index)
  ssh_key_name = var.automation_key
}

resource "cloudca_volume" "elk_cold_data" {
  count = var.data_cold

  name           = format("%s-cold-data%02d", var.cluster_name, count.index + 1)
  environment_id = var.environment_id

  instance_id   = cloudca_instance.elk_cold[count.index].id
  disk_offering = var.disk_offering
  size_in_gb    = var.data_cold_data_disk
}

#=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=
# ELK ingest nodes

resource "cloudca_instance" "elk_ingest" {
  count = var.ingest

  name           = format("%s-ingest-%02d", var.cluster_name, count.index + 1)
  environment_id = var.environment_id
  network_id     = var.network_id
  template       = var.cca_image

  compute_offering       = "Standard"
  cpu_count              = var.ingest_cpu
  memory_in_mb           = var.ingest_memory
  root_volume_size_in_gb = 40

  private_ip   = format("%s.24%d", var.network_cidr, count.index)
  ssh_key_name = var.automation_key
}
resource "cloudca_volume" "elk_ingest_data" {
  count = var.ingest

  name           = format("%s-ingest-data%02d", var.cluster_name, count.index + 1)
  environment_id = var.environment_id

  instance_id   = cloudca_instance.elk_ingest[count.index].id
  disk_offering = var.disk_offering
  size_in_gb    = var.ingest_data_disk
}

#=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=
# ELK kibana nodes

resource "cloudca_instance" "elk_kibana" {
  count = var.kibana

  name           = format("%s-kibana-%02d", var.cluster_name, count.index + 1)
  environment_id = var.environment_id
  network_id     = var.dmznetwork_id
  template       = var.cca_image

  compute_offering       = "Standard"
  cpu_count              = var.kibana_cpu
  memory_in_mb           = var.kibana_memory
  root_volume_size_in_gb = 40

  private_ip   = format("%s.20%d", var.dmznetwork_cidr, count.index)
  ssh_key_name = var.automation_key
}

#=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=
# ELK logstash nodes

resource "cloudca_instance" "elk_logstash" {
  count = var.logstash

  name           = format("%s-logstash-%02d", var.cluster_name, count.index + 1)
  environment_id = var.environment_id
  network_id     = var.dmznetwork_id
  template       = var.cca_image

  compute_offering       = "Standard"
  cpu_count              = var.logstash_cpu
  memory_in_mb           = var.logstash_memory
  root_volume_size_in_gb = 40

  private_ip   = format("%s.20%d", var.dmznetwork_cidr, count.index + 2)
  ssh_key_name = var.automation_key
}
resource "cloudca_volume" "elk_logstash_data" {
  count = var.logstash

  name           = format("%s-logstash-data%02d", var.cluster_name, count.index + 1)
  environment_id = var.environment_id

  instance_id   = cloudca_instance.elk_logstash[count.index].id
  disk_offering = var.disk_offering
  size_in_gb    = var.logstash_data_disk
}

#=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=
# ELK coordination nodes

resource "cloudca_instance" "elk_coordination" {
  count = var.coordination

  name           = format("%s-coordination-%02d", var.cluster_name, count.index + 1)
  environment_id = var.environment_id
  network_id     = var.dmznetwork_id
  template       = var.cca_image

  compute_offering       = "Standard"
  cpu_count              = var.coordination_cpu
  memory_in_mb           = var.coordination_memory
  root_volume_size_in_gb = 40

  private_ip   = format("%s.20%d", var.dmznetwork_cidr, count.index + 5)
  ssh_key_name = var.automation_key
}
resource "cloudca_volume" "elk_coordination_data" {
  count = var.coordination

  name           = format("%s-coordination-data%02d", var.cluster_name, count.index + 1)
  environment_id = var.environment_id

  instance_id   = cloudca_instance.elk_coordination[count.index].id
  disk_offering = var.disk_offering
  size_in_gb    = var.coordination_data_disk
}
