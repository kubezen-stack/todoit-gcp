variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "The environment"
  type        = string
  default     = "dev"
}

variable "network_name" {
  description = "The name of the VPC network"
  type        = string
}

variable "tags" {
  description = "A map of additional tags to assign to resources"
  type        = map(string)
  default     = {}
}