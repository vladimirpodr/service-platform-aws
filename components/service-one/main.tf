### General blurb
terraform {
  backend "s3" {}
  required_providers {
    aws = {
      version = "~> 4.44.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = local.base_tags
  }

  assume_role {
    role_arn = "arn:aws:iam::217004862555:role/project-io-${var.environment}-shared-services-assume-role"
  }
}

### Helm provider
provider "helm" {
  kubernetes {
    host                   = local.eks_config.endpoint
    cluster_ca_certificate = base64decode(local.eks_config.cadata)
    token                  = local.eks_token
  }
}

### Kubernetes provider
provider "kubernetes" {
  host                   = local.eks_config.endpoint
  cluster_ca_certificate = base64decode(local.eks_config.cadata)
  token                  = local.eks_token
}
