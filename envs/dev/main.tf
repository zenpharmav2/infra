
locals {
  project = "pharma"
  env     = "dev"
  region  = "us-east-1"
}
data "aws_caller_identity" "current" {}

module "vpc" {
  source = "../../modules/vpc"


  project = local.project
  env     = local.env
  region  = local.region

  vpc_cidr = "10.0.0.0/16"

  public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs  = ["10.0.3.0/24", "10.0.4.0/24"]
  database_subnet_cidrs = ["10.0.5.0/24", "10.0.6.0/24"]

}

module "iam" {
  source = "../../modules/iam"

  project = local.project
  env     = local.env
  region  = local.region

  # IRSA roles (ESO, ArgoCD, ALB controller) need the EKS OIDC provider.
  # Once the EKS module exists, set this to true and pass its outputs, e.g.:
  #   eks_oidc_provider_arn = module.eks.oidc_provider_arn
  #   eks_oidc_provider_url = module.eks.cluster_oidc_issuer_url
  enable_irsa_roles = false

  # GitHub Actions: these repos/branches may assume the CI role
  github_org      = "zenpharmav2"
  github_repos    = ["frontend", "backend"]
  github_branches = ["main", "develop"]
}
