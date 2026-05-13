locals {
  common_labels = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
  }
}

resource "google_compute_network" "main" {
  name                    = "${var.project_name}-network-${var.environment}"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"

  description = "Network for ${var.project_name} ${var.environment}"
}

resource "google_compute_subnetwork" "public" {
  name          = "${var.project_name}-public-subnet-${var.environment}"
  ip_cidr_range = cidrsubnet(var.network_cidr, 2, 0)
  region        = var.region
  network       = google_compute_network.main.id

  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
  }
}

resource "google_compute_router" "router" {
  name    = "${var.project_name}-router-${var.environment}"
  region  = var.region
  network = google_compute_network.main.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.project_name}-nat-${var.environment}"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}