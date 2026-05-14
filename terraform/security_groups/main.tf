locals {
  common_labels = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
    module      = "firewall"
  }
}

resource "google_compute_firewall" "allow_ssh" {
  name        = "${var.project_name}-${var.environment}-allow-ssh"
  description = "Allow SSH access for management"
  network     = var.network_name
  direction   = "INGRESS"
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["app", "jenkins"]
}

resource "google_compute_firewall" "allow_app" {
  name        = "${var.project_name}-${var.environment}-allow-app"
  description = "Allow FastAPI application traffic"
  network     = var.network_name
  direction   = "INGRESS"
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = ["8000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["app"]
}

resource "google_compute_firewall" "allow_postgresql" {
  name        = "${var.project_name}-${var.environment}-allow-postgresql"
  description = "Allow PostgreSQL from app servers only"
  network     = var.network_name
  direction   = "INGRESS"
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_tags = ["app"]
  target_tags = ["database"]
}

resource "google_compute_firewall" "allow_jenkins" {
  name        = "${var.project_name}-${var.environment}-allow-jenkins"
  description = "Allow Jenkins access from specific IPs"
  network     = var.network_name
  direction   = "INGRESS"
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["jenkins"]
}

resource "google_compute_firewall" "allow_outbound" {
  name        = "${var.project_name}-${var.environment}-allow-outbound"
  description = "Allow all outbound traffic"
  network     = var.network_name
  direction   = "EGRESS"
  priority    = 1000

  allow {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]
}