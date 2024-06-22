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

# IAM policy for IRSA
data "aws_iam_policy_document" "opc_maverick_service" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:DescribeAvailabilityZones",
      "ssm:GetParameters"
    ]
  }
}

data "aws_eks_cluster_auth" "eks" {
  name =  local.eks_config.id
}
