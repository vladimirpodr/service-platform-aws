# Environment specific variables
environment             = "dev"

# Peering connections with SaaS platforms.
aiven_vpc_peering_connection_id = ""
aiven_vpc_cidr                  = "10.1.0.0/24"

# Peering connections with SaaS platforms.
atlas_vpc_peering_connection_id = ""
atlas_vpc_cidr                  = "192.168.248.0/21"

# Availability zones
total_azs = 3

# Bucket in Log Archive account to store project logs
log_archive_bucket = "project-io-log-archive-project-logs"

### EKS
# Worker nodegroups
eks_nodegroup_intel = {
  instance_type = "t3.large"
  pool          = "intel"
  taint         = false

  disk_size    = 20
  max_size     = 3
  min_size     = 1
  desired_size = 1
}

# eks_nodegroup_arm64 = {
#   instance_type = "m6g.xlarge"
#   pool          = "arm64"
#   taint         = false

#   disk_size    = 20
#   max_size     = 3
#   min_size     = 1
#   desired_size = 1
# }

# GitOps with ArgoCD config and Flux V2
argocd_google_oauth_client_id   = "xxxxx.apps.googleusercontent.com"
argocd_google_oauth_admin_email = "josh@project.com"

enable_flux2 = true

### RabbitMQ parameters
rabbitmq = {
  enabled                    = true
  apply_immediately          = true
  auto_minor_version_upgrade = true
  deployment_mode            = "SINGLE_INSTANCE"
  engine_version             = "3.10.10"
  instance_type              = "mq.m5.large"
  log_retention_in_days      = 7
}
