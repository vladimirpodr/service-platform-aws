### Workers Node Groups deployment
### Data: EKS Intel Node AMI
data "aws_ami" "eks_node" {
  executable_users = ["all"]
  owners           = ["amazon"]
  most_recent      = true

  filter {
    name   = "name"
    values = ["amazon-eks-node-${module.eks.config.version}-v*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

module "nodegroup-intel" {
  source = "git@github.com:project/aws-terraform-modules.git//eks/nodegroup"

  basename = local.basename
  subnets  = module.eks.eks_subnets

  cluster = module.eks.config
  taint   = var.eks_nodegroup_intel.taint
  pool    = var.eks_nodegroup_intel.pool

  ## Node instance
  instance_type = var.eks_nodegroup_intel.instance_type
  instance_ami  = data.aws_ami.eks_node.id

  ### Node root volume size, Gb
  disk_size  = var.eks_nodegroup_intel.disk_size
  kms_key_id = module.eks-node-ebs-kms.key_arn

  ### Pool size
  max_size     = var.eks_nodegroup_intel.max_size
  min_size     = var.eks_nodegroup_intel.min_size
  desired_size = var.eks_nodegroup_intel.desired_size

  depends_on = [
    module.eks,
    module.eks-node-ebs-kms
  ]
}
