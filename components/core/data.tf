data "aws_availability_zones" "aws_azs" {}

data "aws_caller_identity" "current" {}

# Get AWSReservedSSO* roles for EKS aws-auth map
data "aws_iam_roles" "administratoraccess" {
  name_regex  = "AWSReservedSSO_AdministratorAccess_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

data "aws_iam_roles" "poweruseraccess" {
  name_regex  = "AWSReservedSSO_PowerUserAccess_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

data "aws_iam_roles" "readonlyaccess" {
  name_regex  = "AWSReservedSSO_ReadOnlyAccess_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

### Data Remote States
# Networking Transit Gateway State
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    region   = var.aws_region
    bucket   = "project-io-network-tfstate-bucket"
    key      = "network/networking/terraform.tfstate"
    role_arn = "arn:aws:iam::552249246765:role/project-io-network-shrdsvc-assume-role"
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

# Org Environment Account State
data "terraform_remote_state" "account" {
  backend = "s3"
  config = {
    region   = var.aws_region
    bucket   = "project-io-${var.environment}-tfstate-bucket"
    key      = "${var.environment}/account/terraform.tfstate"
    role_arn = "arn:aws:iam::217004862555:role/project-io-${var.environment}-shared-services-assume-role"
  }
}
