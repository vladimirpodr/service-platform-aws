resource "aws_ssm_parameter" "kafka_admin_secrets" {
  name        = "${local.basename}-kafka-admin-secrets"
  description = "Kafka authorization credentials"
  type        = "SecureString"
  overwrite   = true
  value       = jsonencode({
    "hosts"    : "value"
    "username" : "value"
    "password" : "value"
    "producerTimeout" : "60000"
    "partitionsConsumedConcurrently" : "value"
  })

  # key_id = "alias/aws/ssm"

  lifecycle {
    ignore_changes = [
      value
    ]
  }

  tags = {
    Name = "${local.basename}-kafka-admin-secrets"
  }
}

resource "aws_ssm_parameter" "admin_api_secrets" {
  name        = "${local.basename}-admin-api-secrets"
  description = "Admin API authorization credentials"
  type        = "SecureString"
  overwrite   = true
  value       = jsonencode({
    "token"              : "value"
    "domainServiceToken" : "value"
  })

  # key_id = "alias/aws/ssm"

  lifecycle {
    ignore_changes = [
      value
    ]
  }

  tags = {
    Name = "${local.basename}-admin-api-secrets"
  }
}

resource "aws_ssm_parameter" "mongo_service_secrets" {
  name        = "${local.basename}-mongo-service-secrets"
  description = "MongoDB authorization credentials"
  type        = "SecureString"
  overwrite   = true
  value       = jsonencode({
    "mongoConnString" : "value"
  })

  # key_id = "alias/aws/ssm"

  lifecycle {
    ignore_changes = [
      value
    ]
  }

  tags = {
    Name = "${local.basename}-mongo-service-secrets"
  }
}

resource "aws_ssm_parameter" "rabbitmq_secrets" {
  count = var.rabbitmq.enabled ? 1 : 0

  name        = "${local.basename}-rabbitmq-secrets"
  description = "RabbitMQ authorization config"
  type        = "SecureString"
  overwrite   = true
  value       = jsonencode({
    "protocol" : "amqps"
    "host"     : trimprefix(module.rabbitmq[0].primary_console_url, "https://")
    "port"     : "5671"
    "username" : module.rabbitmq[0].application_username
    "password" : module.rabbitmq[0].application_password
    "vhost"    : "/${var.environment}"
  })

  # key_id = "alias/aws/ssm"

  tags = {
    Name = "${local.basename}-rabbitmq-secrets"
  }
}

resource "aws_ssm_parameter" "launch_darkly_api_secret" {
  name        = "${local.basename}-launch-darkly-api-secrets"
  description = "launch-darkly-api-secrets config"
  type        = "SecureString"
  overwrite   = true
  value       = jsonencode({
    "apiToken" : "api-token"
  })

  # key_id = "alias/aws/ssm"

  lifecycle {
    ignore_changes = [
      value
    ]
  }

  tags = {
    Name = "${local.basename}-launch-darkly-api-secrets"
  }
}


resource "aws_ssm_parameter" "auth0_config" {
  name        = "${local.basename}-auth0-config"
  description = "auth0-config config"
  type        = "SecureString"
  overwrite   = true
  value       = jsonencode({
    "domainServiceClientId" : "value"
    "domainServiceClientSecret" : "value"
    "adminAudience" : "value"
  })

  # key_id = "alias/aws/ssm"

  lifecycle {
    ignore_changes = [
      value
    ]
  }

  tags = {
    Name = "${local.basename}-auth0-config"
  }
}
