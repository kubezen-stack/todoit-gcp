variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "project_name" {
  description = "The name of the project for naming purposes"
  type        = string
}

variable "environment" {
  description = "The environment (e.g., dev, prod)"
  type        = string
}

variable "zone" {
  description = "The GCP zone for the instance"
  type        = string
  default     = "us-central1-a"
}

variable "network_name" {
  description = "The name of the VPC network"
  type        = string
}

variable "subnetwork_name" {
  description = "The name of the subnetwork"
  type        = string
}

variable "machine_type" {
  description = "The machine type for the instance"
  type        = string
  default     = "e2-micro"

  validation {
    condition     = can(regex("^e2-micro$|^e2-small$|^e2-medium$", var.machine_type))
    error_message = "Machine type must be e2-micro, e2-small, or e2-medium."
  }
}

variable "instance_role" {
  description = "Role of the instance (app or jenkins)"
  type        = string
  default     = "app"

  validation {
    condition     = contains(["app", "jenkins"], var.instance_role)
    error_message = "instance_role must be 'app' or 'jenkins'."
  }
}

variable "image" {
  description = "The boot disk image (Ubuntu 22.04)"
  type        = string
  default     = "ubuntu-2204-lts"
}

variable "boot_disk_size" {
  description = "The size of the boot disk in GB"
  type        = number
  default     = 20

  validation {
    condition     = var.boot_disk_size >= 20 && var.boot_disk_size <= 10000
    error_message = "Boot disk size must be between 20 and 10000 GB."
  }
}