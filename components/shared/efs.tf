### EFS
module "efs" {
  source = "git@github.com:project/aws-terraform-modules.git//efs"

  name = local.basename

  vpc_id  = data.terraform_remote_state.core.outputs.vpc.id
  subnets = data.terraform_remote_state.core.outputs.vpc_private_subnets_ids

  kms_key_id = local.data_encryption_kms_key

  src_groups = {
    eks-nodes = data.terraform_remote_state.core.outputs.eks_cluster_sg
  }

  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
}
