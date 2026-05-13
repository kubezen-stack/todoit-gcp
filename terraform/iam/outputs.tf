output "ansible_sa_email" {
  value       = google_service_account.ansible.email
  description = "Email of the Ansible service account"
}

output "ansible_sa_key" {
  value       = google_service_account_key.ansible_key.private_key
  description = "Private key of the Ansible service account"
  sensitive   = true
}