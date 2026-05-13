output "allow_ssh_rule_name" {
  description = "The name of the SSH firewall rule"
  value       = google_compute_firewall.allow_ssh.name
}

output "allow_app_rule_name" {
  description = "The name of the app firewall rule"
  value       = google_compute_firewall.allow_app.name
}

output "allow_postgresql_rule_name" {
  description = "The name of the PostgreSQL firewall rule"
  value       = google_compute_firewall.allow_postgresql.name
}