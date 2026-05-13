output "network_name" {
  description = "GCP Network name"
  value       = module.vpc.network_name
}

output "subnet_name" {
  description = "GCP Subnet name"
  value       = module.vpc.public_subnet_name
}

output "instance_name" {
  description = "Compute instance name"
  value       = module.compute.instance_name
}

output "instance_internal_ip" {
  description = "Internal IP of the compute instance"
  value       = module.compute.internal_ip
}

output "instance_external_ip" {
  description = "External IP of the compute instance"
  value       = module.compute.external_ip
}