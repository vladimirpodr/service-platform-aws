# Core State
data "terraform_remote_state" "core" {
  backend = "s3"
  config = {
    region   = var.aws_region
    bucket   = "project-io-${var.environment}-tfstate-bucket"
    key      = "${var.environment}/project-io/terraform.tfstate"
    role_arn = "arn:aws:iam::217004862555:role/project-io-${var.environment}-shared-services-assume-role"
  }
}

# Shared-Services Security State
data "terraform_remote_state" "shrdsvc_security" {
  backend = "s3"
  config = {
    region   = var.aws_region
    bucket   = "project-io-shrdsvc-tfstate-bucket"
    key      = "shared-services/security/terraform.tfstate"
    role_arn = "arn:aws:iam::665073570289:role/project-io-shrdsvc-assume-role"
  }
}
