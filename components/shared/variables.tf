### GENERAL
variable "project_name" {
  description = "Project name."
  type        = string
}

variable "root_domain" {
  description = "Project Route53 Hosted Zone domain."
  type        = string
}

variable "aws_region" {
  description = "Main region for all accounts and resources."
  type        = string
}

variable "cidr_blocks" {
  description = " CIDR Blocks for the VPC networks."
  type        = map
}

### SHARED
variable "environment" {
  description = "Project environment name."
  type        = string
}

### MQ Broker parameters
variable "rabbitmq" {
  description = "Amazon MQ RabbitMQ instance deployment parameters."
  type        = map
}
