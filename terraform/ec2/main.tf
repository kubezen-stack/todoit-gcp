locals {
  common_labels = {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
    module      = "compute"
  }

  instance_name = "${var.project_name}-${var.environment}-${var.instance_role}-instance"
}

resource "google_compute_instance" "app_instance" {
  name         = local.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.boot_disk_size
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = var.network_name
    subnetwork = var.subnetwork_name

    access_config {}
  }

  metadata_startup_script = <<EOT
    echo "maksym23102006_gmail_com ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/ansible-user
  EOT

  metadata = {
    enable-oslogin = "TRUE"
  }

  labels = merge(local.common_labels, {
    name = local.instance_name
    role = var.instance_role
  })

  tags = [var.instance_role, "terraform"]

  lifecycle {
    ignore_changes = []
  }

  service_account {
    email  = var.service_account_email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}