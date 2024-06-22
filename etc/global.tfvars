# Global variables
project_name = "project-io"
root_domain  = "project.io"
aws_region   = "us-east-1"

cidr_blocks = {
  project = "10.80.0.0/12"
  dev     = "10.81.0.0/19"
  vpn     = "10.80.9.0/25"
  cicd    = "10.80.16.0/24"
}

gitops_repo = "https://github.com/project/project-gitops.git"
