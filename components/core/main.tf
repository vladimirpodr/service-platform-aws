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

### Declare Transit AWS Provider with assumed role to have access to account with shared Transit Gateway
provider "aws" {
  alias  = "transit"
  region = "us-east-1"

  default_tags {
    tags = local.base_tags
  }

  assume_role {
    role_arn = "arn:aws:iam::552249246765:role/project-io-network-shrdsvc-assume-role"
  }
}

### Helm provider
provider "helm" {
  kubernetes {
    host                   = module.eks.config.endpoint
    cluster_ca_certificate = base64decode(module.eks.config.cadata)
    token                  = module.eks.eks_token
  }
}

### Kubernetes provider
provider "kubernetes" {
  host                   = module.eks.config.endpoint
  cluster_ca_certificate = base64decode(module.eks.config.cadata)
  token                  = module.eks.eks_token
}
