resource "aws_iam_policy" "opc_maverick_service" {
  name        = "${local.basename}-${local.opc_maverick_service}-irsa-policy"
  description = "IAM Policy for ${local.opc_maverick_service} app IRSA role."
  policy      = data.aws_iam_policy_document.opc_maverick_service.json
  tags        = {
    Name = "${local.opc_maverick_service}-irsa-policy"
  }
}

module "irsa" {
  source  = "git@github.com:project/aws-terraform-modules.git//eks/add-ons/irsa?ref=main"

  name                              = "${local.basename}-${local.opc_maverick_service}"
  create_kubernetes_service_account = true
  kubernetes_namespace              = local.kubernetes_namespace
  kubernetes_service_account        = local.opc_maverick_service
  irsa_iam_policies                 = [aws_iam_policy.opc_maverick_service.arn]
  eks_cluster_id                    = local.eks_config.id
  eks_oidc_provider_arn             = local.eks_config.oidc_provider_arn
}
