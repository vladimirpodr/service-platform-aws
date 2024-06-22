# ### Workers Node Groups deployment
# ### Data: EKS Graviton Node AMI
# data "aws_ami" "eks_arm64_node" {
#   executable_users = ["all"]
#   owners           = ["amazon"]
#   most_recent      = true

#   filter {
#     name   = "name"
#     values = ["amazon-eks-arm64-node-${module.eks.config.version}-v*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   filter {
#     name   = "architecture"
#     values = ["arm64"]
#   }
# }

# module "nodegroup-arm64" {
#   source = "git@github.com:project/aws-terraform-modules.git//eks/nodegroup"

#   basename     = local.basename
#   subnets      = module.eks.eks_subnets

#   cluster      = module.eks.config
#   taint        = var.taint

#   ## Node instance type
#   instance_type = var.arm64_instance_type
#   instance_ami  = data.aws_ami.eks_arm64_node.id
#   ### Node root volume size, Gb
#   disk_size  = var.disk_size
#   kms_key_id = module.eks-node-ebs-kms.key_arn

#   ### Pool size
#   max_size     = var.max_size
#   min_size     = var.min_size
#   desired_size = var.desired_size

#   depends_on = [
#     module.eks,
#     module.eks-kms
#   ]
# }
