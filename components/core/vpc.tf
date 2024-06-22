### VPC
module "vpc" {
  source = "git@github.com:project/aws-terraform-modules.git//network/vpc?ref=main"

  name = local.basename
  cidr = local.vpc_cidr

  public_zones   = local.zone_names
  private_zones  = local.zone_names
  isolated_zones = local.zone_names

  public_subnets_bits   = 5
  public_subnets_base   = 0
  isolated_subnets_bits = 5
  isolated_subnets_base = 4
  private_subnets_bits  = 2
  private_subnets_base  = 1

  has_nat                  = false
  vpc_s3_endpoint_enable   = true
  vpc_flow_logs_bucket_arn = var.log_archive_bucket

  public_subnets_tags  = { "kubernetes.io/role/elb" = "1" }
  private_subnets_tags = { "kubernetes.io/role/internal-elb" = "1" }
}

# Attach the VPC to Transit gateway
module "tgw-attachment" {
  source = "git@github.com:project/aws-terraform-modules.git//transit-gateway/attachment/"

  providers = {
    aws.transit = aws.transit
  }

  name = local.basename

  transit_gateway_id                = local.tgw.id
  transit_gateway_association_rt_id = local.tgw.association_rt_id
  transit_gateway_propagation_rt_id = local.tgw.propagation_rt_id

  vpc_id  = module.vpc.id
  subnets = module.vpc.private_subnets.ids

  # Add attached VPC RT routes to peered VPCs or Internet via TGW.
  vpc_route_peer_cidr = "0.0.0.0/0"
  vpc_route_tables    = concat(module.vpc.rts_private, [module.vpc.rt_default])
}
