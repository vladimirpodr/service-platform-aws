### Outputs
output "vpc" {
  value = {
    id   = module.vpc.id
    name = module.vpc.name
    cidr = local.vpc_cidr

    rt_default  = module.vpc.rt_default
    rt_public   = module.vpc.rt_public
    rts_private = module.vpc.rts_private
  }
}

output "eks_config" {
  value = module.eks.config
}

output "isolated_subnets" {
  value = module.vpc.isolated_subnets
}

output "eks_subnets" {
  value = module.eks.eks_subnets
}

output "eks_aws_auth" {
  value = module.eks-auth.aws_auth_context
}

output "aws_route53_zones" {
  value = {for k, v in aws_route53_zone.main: k => v.name_servers}
}

output "vpc_private_subnets_ids" {
  value = module.vpc.private_subnets.ids
}

output "eks_cluster_sg" {
  value = module.eks.config.cluster_sg
}
