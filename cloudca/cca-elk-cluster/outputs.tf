output "elk_master_names" {
  description = "List of master names"
  value       = cloudca_instance.elk_master.*.name
}
output "elk_master_ips" {
  description = "List of master ips"
  value       = cloudca_instance.elk_master.*.private_ip
}

output "elk_hot_names" {
  description = "List of hot node names"
  value       = cloudca_instance.elk_hot.*.name
}
output "elk_hot_ips" {
  description = "List of hot node ips"
  value       = cloudca_instance.elk_hot.*.private_ip
}

output "elk_warm_names" {
  description = "List of warm node names"
  value       = cloudca_instance.elk_warm.*.name
}
output "elk_warm_ips" {
  description = "List of warm node ips"
  value       = cloudca_instance.elk_warm.*.private_ip
}

output "elk_cold_names" {
  description = "List of cold node names"
  value       = cloudca_instance.elk_cold.*.name
}
output "elk_cold_ips" {
  description = "List of cold node ips"
  value       = cloudca_instance.elk_cold.*.private_ip
}

output "kibana_names" {
  description = "List of kibana names"
  value       = cloudca_instance.elk_kibana.*.name
}
output "kibana_ips" {
  description = "List of kibana ips"
  value       = cloudca_instance.elk_kibana.*.private_ip
}

output "elk_logstash_names" {
  description = "List of logstash names"
  value       = cloudca_instance.elk_logstash.*.name
}
output "elk_logstash_ips" {
  description = "List of logstash ips"
  value       = cloudca_instance.elk_logstash.*.private_ip
}

output "elk_ingest_names" {
  description = "List of ingest names"
  value       = cloudca_instance.elk_ingest.*.name
}
output "elk_ingest_ips" {
  description = "List of ingest ips"
  value       = cloudca_instance.elk_ingest.*.private_ip
}

output "elk_coordination_names" {
  description = "List of coordination names"
  value       = cloudca_instance.elk_coordination.*.name
}
output "elk_coordination_ips" {
  description = "List of coordination ips"
  value       = cloudca_instance.elk_coordination.*.private_ip
}
