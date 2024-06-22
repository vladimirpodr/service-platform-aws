### GENERAL
variable "project_name" {
  description = "Project name."
  type        = string
}

variable "root_domain" {
  description = "Project Route53 Hosted Zone domain."
  type        = string
}

variable "aws_region" {
  description = "Main region for all accounts and resources."
  type        = string
}

variable "cidr_blocks" {
  description = " CIDR Blocks for the VPC networks."
  type        = map
}

variable "gitops_repo" {
  description = "Repository URL that includes workloads and other HELM charts for GitOps process"
  type        = string
  default     = ""
}

### SHARED
variable "environment" {
  description = "Project environment name."
  type        = string
}
