locals {
  common_labels = {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
    module      = "compute"
  }

  instance_name = "${var.project_name}-${var.environment}-${var.instance_role}-instance"
  ssh_public_key = var.ssh_pub_key_file != "" ? file(var.ssh_pub_key_file) : (
    var.ssh_pub_key_secret_name != "" ? data.google_secret_manager_secret_version.ansible_pub_key[0].secret_data : ""
  )
  ssh_login_user = var.service_account_unique_id != "" ? "sa_${var.service_account_unique_id}" : "ubuntu"
}

data "google_secret_manager_secret_version" "ansible_pub_key" {
  count   = var.ssh_pub_key_secret_name != "" ? 1 : 0
  project = var.project_id
  secret  = var.ssh_pub_key_secret_name
  version = var.ssh_pub_key_secret_version
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

  metadata = merge(
    {
      enable-oslogin = "TRUE"
    },
    local.ssh_public_key != "" ? {
      "ssh-keys" = "${local.ssh_login_user}:${local.ssh_public_key}"
    } : {}
  )

  labels = merge(local.common_labels, {
    name = local.instance_name
    role = var.instance_role
  })

  tags = [var.instance_role, "terraform"]

  lifecycle {
    ignore_changes = [
      metadata["ssh-keys"]
    ]
  }
}