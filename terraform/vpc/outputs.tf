output "network_id" {
  description = "The ID of the network"
  value       = google_compute_network.main.id
}

output "network_name" {
  description = "The name of the network"
  value       = google_compute_network.main.name
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = google_compute_subnetwork.public.id
}

output "public_subnet_name" {
  description = "The name of the public subnet"
  value       = google_compute_subnetwork.public.name
}