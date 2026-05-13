module "vpc" {
  source = "./vpc"

  project_id   = var.gcp_project_id
  project_name = var.project_name
  environment  = var.environment
  region       = var.gcp_region
  network_cidr = var.network_cidr
}

module "security_groups" {
  source = "./security_groups"

  project_id   = var.gcp_project_id
  project_name = var.project_name
  environment  = var.environment
  network_name = module.vpc.network_name
}

module "compute" {
  source = "./ec2"

  project_id       = var.gcp_project_id
  project_name     = var.project_name
  environment      = var.environment
  zone             = var.app_zone
  network_name     = module.vpc.network_name
  subnetwork_name  = module.vpc.public_subnet_name
  machine_type     = "e2-micro"
  boot_disk_size   = 20
  image            = "ubuntu-2204-lts"
  startup_script   = ""
}