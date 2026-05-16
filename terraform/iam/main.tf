locals {
  common_labels = {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
    module      = "iam"
  }
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

resource "google_project_iam_member" "ansible_sa_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.ansible.email}"
}

resource "google_project_iam_member" "ansible_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.ansible.email}"
}

resource "google_project_iam_member" "ansible_os_admin_login" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.ansible.email}"
}

resource "google_artifact_registry_repository" "todo_app" {
  location      = var.region
  repository_id = "todo-app"
  format        = "DOCKER"
  project       = var.project_id
}

resource "google_artifact_registry_repository_iam_member" "sa_reader" {
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.todo_app.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.ansible.email}"
}

resource "google_artifact_registry_repository_iam_member" "sa_writer" {
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.todo_app.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.ansible.email}"
}

resource "google_service_account_key" "ansible_key" {
  service_account_id = google_service_account.ansible.name
}