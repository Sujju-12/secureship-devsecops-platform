# Optional validation example only; no AWS resources are created.
provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region for optional future exercises."
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project identifier for optional infrastructure exercises."
  type        = string
  default     = "secureship"
}

locals {
  common_tags = {
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Environment = "lab"
  }
}

output "project_name" {
  description = "Project identifier used by the lab."
  value       = var.project_name
}
