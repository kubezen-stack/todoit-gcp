output "instance_id" {
  description = "The instance ID"
  value       = google_compute_instance.app_instance.id
}

output "instance_name" {
  description = "The instance name"
  value       = google_compute_instance.app_instance.name
}

output "internal_ip" {
  description = "The internal IP address of the instance"
  value       = google_compute_instance.app_instance.network_interface[0].network_ip
}

output "external_ip" {
  description = "The external IP address of the instance"
  value       = google_compute_instance.app_instance.network_interface[0].access_config[0].nat_ip
}