locals {
  common_labels = {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
    module      = "compute"
  }

  instance_name = "${var.project_name}-${var.environment}-instance"
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

  metadata = {
    enable-oslogin = "TRUE"
  }

  metadata_startup_script = var.startup_script

  tags = ["app", "terraform"]

  labels = merge(local.common_labels, {
    name = local.instance_name
    role = "app"
  })

  lifecycle {
    ignore_changes = [
      metadata["ssh-keys"]
    ]
  }
}