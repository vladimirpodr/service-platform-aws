# Deploy RabbitMQ instance
module "rabbitmq" {
  source = "git@github.com:project/aws-terraform-modules.git//rabbitmq?ref=main"

  count = var.rabbitmq.enabled ? 1 : 0

  name                       = "${local.basename}-rabbitmq"
  apply_immediately          = var.rabbitmq.apply_immediately
  auto_minor_version_upgrade = var.rabbitmq.auto_minor_version_upgrade
  deployment_mode            = var.rabbitmq.deployment_mode
  engine_version             = var.rabbitmq.engine_version
  host_instance_type         = var.rabbitmq.instance_type
  publicly_accessible        = false
  general_log_enabled        = true
  audit_log_enabled          = false
  log_retention_in_days      = var.rabbitmq.log_retention_in_days
  vpc_id                     = local.vpc_id
  subnet_ids                 = local.rabbitmq_subnet
  broker_security_groups     = [aws_security_group.rabbitmq[0].id]

  # Maintenance window
  maintenance_day_of_week = "SATURDAY"
  maintenance_time_of_day = "06:00"
  maintenance_time_zone   = "UTC"
}

### Security Groups
resource "aws_security_group" "rabbitmq" {
  count = var.rabbitmq.enabled ? 1 : 0

  vpc_id = local.vpc_id
  name   = "${local.basename}-rabbitmq-sg"

  tags = {
    Name = "${local.basename}-rabbitmq-sg"
  }
}

resource "aws_security_group_rule" "rabbitmq_eks_nodes_access" {
  count = var.rabbitmq.enabled ? 1 : 0

  description = "Access from EKS nodes using AMQP"

  security_group_id = aws_security_group.rabbitmq[0].id

  type      = "ingress"
  protocol  = "tcp"
  from_port = 5671
  to_port   = 5671

  source_security_group_id = local.eks_nodes_sg_id
}

resource "aws_security_group_rule" "rabbitmq_vpn_access" {
  count = var.rabbitmq.enabled ? 1 : 0

  description = "Access via Client VPN using AMQP"

  security_group_id = aws_security_group.rabbitmq[0].id

  type      = "ingress"
  protocol  = "tcp"
  from_port = 5671
  to_port   = 5671

  cidr_blocks = [local.vpn_vpc_cidr]
}

resource "aws_security_group_rule" "rabbitmq_vpn_https_access" {
  count = var.rabbitmq.enabled ? 1 : 0

  description = "Access via Client VPN using HTTPS"

  security_group_id = aws_security_group.rabbitmq[0].id

  type      = "ingress"
  protocol  = "tcp"
  from_port = 443
  to_port   = 443

  cidr_blocks = [local.vpn_vpc_cidr]
}
