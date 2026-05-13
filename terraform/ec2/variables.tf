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
    condition     = can(regex("^e2-micro$|^t2d-standard-1$", var.machine_type))
    error_message = "Use e2-micro or similar small machine types."
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

variable "startup_script" {
  description = "Startup script to run on instance boot"
  type        = string
  default     = ""
}
  default     = 20
}

variable "storage_type" {
  description = "The type of the root EBS volume"
  type        = string
  default     = "gp2"

  validation {
    condition     = contains(["gp2", "gp3"], var.storage_type)
    error_message = "Storage type must be gp2 or gp3."
  }
}

variable "tags" {
  description = "A map of additional tags to assign to the EC2 instance"
  type        = map(string)
  default     = {}
}