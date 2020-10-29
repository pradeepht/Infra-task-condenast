provider "aws" {
  version = "~> 2.0"
  region  = "ap-south-1"
}

resource "aws_ecr_repository" "node_app_ecr_repo" {
  name = "node-app-ecr-repo"
}

