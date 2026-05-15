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
  value       = module.compute_app.instance_name
}

output "instance_external_ip" {
  description = "External IP of the compute instance"
  value       = module.compute_app.external_ip
}

output "jenkins_external_ip" {
  description = "External IP of Jenkins instance"
  value       = module.compute_jenkins.external_ip
}

output "ansible_sa_email" {
  description = "Ansible service account email"
  value       = module.iam.ansible_sa_email
}

output "ansible_sa_key" {
  description = "Ansible service account key"
  value       = module.iam.ansible_sa_key
  sensitive   = true
}

output "ansible_sa_unique_id" {
  description = "Ansible service account unique ID"
  value       = module.iam.ansible_sa_unique_id
}