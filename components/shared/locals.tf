### Handy locals
locals {
  # Base name prefix
  basename  = "${var.project_name}-${var.environment}"
  component = "shared"

  data_encryption_kms_key = data.terraform_remote_state.shrdsvc_security.outputs.data_kms_arns[var.environment]

  # Base resource-independent tags
  base_tags = {
    Application = var.project_name
    Environment = var.environment
    Component   = local.component
  }

  # Network config
  vpn_vpc_cidr     = var.cidr_blocks.vpn
  vpc_id           = data.terraform_remote_state.core.outputs.vpc.id
  subnet_ids       = data.terraform_remote_state.core.outputs.isolated_subnets.ids
  rabbitmq_subnet  = slice(local.subnet_ids, 0, 1)
  eks_nodes_sg_id  = data.terraform_remote_state.core.outputs.eks_config.cluster_sg
}
