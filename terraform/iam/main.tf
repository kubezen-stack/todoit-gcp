locals {
  common_labels = {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
    module      = "iam"
  }

  instance_name = "${var.project_name}-${var.environment}-instance"
}

resource "google_service_account" "ansible" {
  account_id   = "${var.project_name}-${var.environment}-sa"
  display_name = "Service Account for ${var.project_name} in ${var.environment}"
  project      = var.project_id
}

resource "google_project_iam_member" "ansible_os_login" {
  project = var.project_id
  role    = "roles/compute.osLogin"
  member  = "serviceAccount:${google_service_account.ansible.email}"
}

resource "google_project_iam_member" "ansible_os_admin_login" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.ansible.email}"
}

resource "google_service_account_key" "ansible_key" {
  service_account_id = google_service_account.ansible.name
}