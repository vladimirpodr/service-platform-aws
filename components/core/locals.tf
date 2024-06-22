### Handy locals
locals {
  # Base name prefix
  basename  = "${var.project_name}-${var.environment}"
  component = "core"

  environment_domain  = "${var.environment}.${var.root_domain}"
  hosted_environments = concat([var.environment], var.additional_environments)

  lb_access_logs_s3_bucket_id = data.terraform_remote_state.account.outputs.lb_access_logs_s3_bucket_id

  # Availability zones
  zone_names = slice(data.aws_availability_zones.aws_azs.names, 0, var.total_azs)
  zone_ids   = slice(data.aws_availability_zones.aws_azs.zone_ids, 0, var.total_azs)

  # Notwork configs
  vpc_cidr      = var.cidr_blocks[var.environment]
  vpn_vpc_cidr  = var.cidr_blocks.vpn
  cicd_vpc_cidr = var.cidr_blocks.cicd

  # Shared Transit Gateway config
  tgw = data.terraform_remote_state.network.outputs.tgw

  # Base resource-independent tags
  base_tags = {
    Application = var.project_name
    Environment = var.environment
    Component   = local.component
  }

  #GitOps with ArgoCD config
  git_secret_arn                           = data.terraform_remote_state.shrdsvc_security.outputs.github_pat_secret_arn
  argocd_google_groups_json_secret_arn     = data.terraform_remote_state.shrdsvc_security.outputs.argocd_google_groups_json_secret_arns[var.environment]
  argocd_google_oauth_client_secret_arn    = data.terraform_remote_state.shrdsvc_security.outputs.argocd_google_oauth_client_secret_arns[var.environment]
  datatdog_api_key_secret_arn              = data.terraform_remote_state.shrdsvc_security.outputs.datadog_api_key_secret_arns[var.environment]
  keda_auth_kafka_credential_secret_arn    = data.terraform_remote_state.shrdsvc_security.outputs.keda_auth_kafka_credential_secret_arns[var.environment]
  keda_auth_rabbitmq_credential_secret_arn = data.terraform_remote_state.shrdsvc_security.outputs.keda_auth_rabbitmq_credential_secret_arns[var.environment]

  # EKS local variables
  eks_admin_role      = one(data.aws_iam_roles.administratoraccess.names)
  eks_power_user_role = one(data.aws_iam_roles.poweruseraccess.names)
  eks_read_only_role  = one(data.aws_iam_roles.readonlyaccess.names)
}
