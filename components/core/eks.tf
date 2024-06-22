### EKS Cluster
module "eks" {
  source = "git@github.com:project/aws-terraform-modules.git//eks/cluster/"

  name = "${local.basename}-eks"

  eks_version               = "1.23"
  enable_irsa               = true
  enable_cluster_encryption = true
  cluster_encryption_config = [{
    resources = ["secrets"]
  }]

  vpc_id  = module.vpc.id
  subnets = module.vpc.private_subnets.ids

  endpoint_private_access = true
  endpoint_public_access  = false

  cluster_logs_retention_in_days = 7
  depends_on = [
    module.vpc
  ]
}

# Ensure nodes can connect to cluster
module "eks-auth" {
  source = "git@github.com:project/aws-terraform-modules.git//eks/aws-auth/"

  basename = local.basename

  pools = [
    "intel",
    "arm64"
  ]

  admin_role      = local.eks_admin_role
  power_user_role = local.eks_power_user_role
  read_only_role  = local.eks_read_only_role

  depends_on = [
    module.eks,
    module.tgw-attachment,
    aws_security_group_rule.access_pipe_to_eks_api
  ]
}

# Allow access from VPN VPC to EKS API
resource "aws_security_group_rule" "access_vpn_to_eks_api" {
  description       = "Allow access from VPN VPC to EKS API"
  security_group_id = module.eks.config.sg_id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = [local.vpn_vpc_cidr]
}

# Allow access from Pipeline VPC (CodeBuild) to EKS API
resource "aws_security_group_rule" "access_pipe_to_eks_api" {
  description       = "Allow access from Pipeline VPC (CodeBuild) to EKS API"
  security_group_id = module.eks.config.sg_id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = [local.cicd_vpc_cidr]
}

# Create KMS keys for EKS node EBS volumes
module "eks-node-ebs-kms" {
  source = "git@github.com:project/aws-terraform-modules.git//kms/"

  description             = coalesce("${local.basename} cluster node EBS volumes encryption key")
  deletion_window_in_days = 7

  # Policy
  enable_default_policy = true
  key_users = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling", # required for the ASG to manage encrypted volumes for nodes
    module.eks.role.arn                                                                                                                         # required for the cluster / persistentvolume-controller to create encrypted PVCs
  ]
  key_users_with_service = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling", # required for the ASG to manage encrypted volumes for nodes
    module.eks.role.arn                                                                                                                         # required for the cluster / persistentvolume-controller to create encrypted PVCs
  ]

  # Aliases
  aliases = ["eks/${local.basename}-eks-node-ebs-kms-key"]

  tags = {
    Name = "${local.basename}-eks-node-ebs-kms-key"
  }
}

module "eks-add-ons-git-ops" {
  source = "git@github.com:project/aws-terraform-modules.git//eks/add-ons?ref=main"

  name                = "${local.basename}-eks"
  eks_cluster_id      = module.eks.id
  data_plane_wait_arn = module.nodegroup-intel.node_group_arn

  project_name             = var.project_name
  environment              = var.environment
  domain_name              = local.environment_domain
  domain_certificate_arn   = module.certificate[var.environment].arn
  lb_access_logs_s3_bucket = local.lb_access_logs_s3_bucket_id

  enable_argocd = true
  argocd_helm_config = {
    version = "5.16.6"
  }

  argocd_repositories = {
    aws-terraform-modules = {
      url            = "https://github.com/project/aws-terraform-modules.git"
      git_secret_arn = local.git_secret_arn
      branch         = "main"
    }
    helm-charts = {
      url            = var.gitops_repo
      git_secret_arn = local.git_secret_arn
      branch         = "feat/pilot-migration"
    }
  }

  argocd_application = {
    path               = "eks-add-ons-helm/chart"
    repo_url           = "https://github.com/project/aws-terraform-modules.git"
  }

  # ArgoCD SSO: OpenID Connect plus Google Groups using Dex
  argocd_enable_sso                     = true
  argocd_google_groups_json_secret_arn  = local.argocd_google_groups_json_secret_arn
  argocd_google_oauth_client_id         = var.argocd_google_oauth_client_id
  argocd_google_oauth_client_secret_arn = local.argocd_google_oauth_client_secret_arn
  argocd_google_oauth_admin_email       = var.argocd_google_oauth_admin_email

  # Enable and deploy addo-ons via GitOps with ArgoCD
  enable_aws_efs_csi_driver                    = true
  enable_aws_load_balancer_controller          = true
  enable_cluster_autoscaler                    = true
  enable_external_dns                          = true
  external_dns_route53_zone_arns               = values(aws_route53_zone.main)[*].arn
  enable_ingress_nginx                         = false
  enable_karpenter                             = false
  enable_keda                                  = true
  enable_metrics_server                        = true
  enable_secrets_store_csi_driver_provider_aws = true
  enable_datadog_agent                         = true
  datatdog_api_key_secret_arn                  = local.datatdog_api_key_secret_arn
  enable_flux2                                 = var.enable_flux2

  keda_auth_kafka_credential_secret_arn    = local.keda_auth_kafka_credential_secret_arn
  #keda_auth_rabbitmq_credential_secret_arn = local.keda_auth_rabbitmq_credential_secret_arn

  depends_on = [
    module.eks
  ]
}

module "argocd_project" {
  source = "git@github.com:project/aws-terraform-modules.git//eks/add-ons/argocd/project?ref=main"

  for_each = toset(local.hosted_environments)

  project_name = var.project_name
  environment  = each.key

  depends_on = [
    module.eks-add-ons-git-ops
  ]
}
