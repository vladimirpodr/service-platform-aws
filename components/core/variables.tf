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

### CORE
variable "environment" {
  description = "Project environment name."
  type        = string
}

variable "additional_environments" {
  description = "Additional sub environments in a consolidated environment."
  type        = list
  default     = []
}

variable "log_archive_bucket" {
  description = "Central log archive bucket."
  type        = string
}

# Network params
variable "total_azs" {
  description = "The total amount of Availability Zones in use."
  type        = number
  default     = 3
}

# Peering connections with SaaS platforms.
variable "aiven_vpc_peering_connection_id" {
  description = "Id of peering connection with Aiven SaaS platform network."
  type        = string
  default     = ""
}

variable "aiven_vpc_cidr" {
  description = "Aiven SaaS platform VPC CIDR."
  type        = string
  default     = ""
}

variable "atlas_vpc_peering_connection_id" {
  description = "Id of peering connection with Atlas SaaS platform network."
  type        = string
  default     = ""
}

variable "atlas_vpc_cidr" {
  description = "Atlas SaaS platform VPC CIDR."
  type        = string
  default     = ""
}

### EKS variables
# Worker variables
variable "eks_nodegroup_intel" {
  description = "Config for EKS nodes that are based on Intel instances."
  type        = map
}

# variable "eks_nodegroup_arm64" {
#   description = "Config for EKS nodes that are based on ARM instances."
#   type = map
# }

# GitOps with ArgoCD config
variable "argocd_google_oauth_client_id" {
  description = "Google OAuth client id to configure ArgoCD SSO."
  type        = string
  default     = ""
}

variable "argocd_google_oauth_admin_email" {
  description = "Google OAuth administrator email to configure ArgoCD SSO."
  type    = string
  default = ""
}

variable "gitops_repo" {
  description = "Repository URL that includes workloads and other HELM charts for GitOps process"
  type        = string
  default     = ""
}

variable "enable_flux2" {
  description = "Enable/Disable Image updating with Flux V2 Image Controller"
  type        = bool
  default     = false
}
