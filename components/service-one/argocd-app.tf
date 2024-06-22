resource "kubernetes_namespace_v1" "plunger_lift" {
  metadata {
    name = local.kubernetes_namespace
  }
}

module "plunger_lift_argocd_app" {
  source = "git@github.com:project/aws-terraform-modules.git//eks/add-ons/argocd/application?ref=main"

  applications = {
    service-one = {
      environment = var.environment
      project     = "${var.project_name}-${var.environment}"
      namespace   = local.kubernetes_namespace

      auto_sync_policy = "enabled"

      repo_url        = var.gitops_repo
      target_revision = "feat/pilot-migration" # TODO: replace with HEAD after merge branch with workload config into main
      path            = "apps/${local.component}"

      value_file = "values-${var.environment}.yaml"
      values = {
        opc-maverick-service = {
          serviceAccount = {
            name = local.opc_maverick_service
          }
        }
      }
    }
  }

  depends_on = [kubernetes_namespace_v1.plunger_lift]
}
