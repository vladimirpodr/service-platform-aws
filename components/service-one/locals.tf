### Handy locals
locals {
  # Base name prefix
  basename  = "${var.project_name}-${var.environment}"
  component = "service-one"

  kubernetes_namespace = "${var.environment}-${local.component}"

  # Applications
  opc_maverick_service = "opc-maverick-service"

  # Base resource-independent tags
  base_tags = {
    Application = var.project_name
    Environment = var.environment
    Component   = local.component
  }

  # Get EKS Config from the remote state
  eks_config = data.terraform_remote_state.core.outputs.eks_config
  eks_token  = data.aws_eks_cluster_auth.eks.token
}
