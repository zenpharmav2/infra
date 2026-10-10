variable "project" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name (dev, qa, prod)"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# ---------------------------------------------------------------------------
# EKS OIDC (IRSA) — used by External Secrets, ArgoCD and the ALB controller
# ---------------------------------------------------------------------------

variable "enable_irsa_roles" {
  description = "Create the IRSA roles (ESO, ArgoCD, ALB controller). Requires an EKS OIDC provider."
  type        = bool
  default     = false
}

variable "eks_oidc_provider_arn" {
  description = "ARN of the EKS cluster IAM OIDC provider"
  type        = string
  default     = null
}

variable "eks_oidc_provider_url" {
  description = "Issuer URL of the EKS cluster OIDC provider (with or without https://)"
  type        = string
  default     = null
}

# External Secrets Operator
variable "external_secrets_namespace" {
  description = "Namespace of the External Secrets Operator service account"
  type        = string
  default     = "external-secrets"
}

variable "external_secrets_service_account" {
  description = "Name of the External Secrets Operator service account"
  type        = string
  default     = "external-secrets"
}

variable "external_secrets_secret_arns" {
  description = "Secrets Manager ARNs ESO may read. Defaults to all secrets under /<project>/* in this account"
  type        = list(string)
  default     = []
}

# ArgoCD
variable "argocd_namespace" {
  description = "Namespace ArgoCD is installed in"
  type        = string
  default     = "argocd"
}

variable "argocd_service_accounts" {
  description = "ArgoCD service accounts allowed to assume the role"
  type        = list(string)
  default     = ["argocd-application-controller"]
}

variable "argocd_policy_arns" {
  description = "Managed policy ARNs to attach to the ArgoCD role (e.g. AmazonEC2ContainerRegistryReadOnly for OCI Helm charts in ECR)"
  type        = list(string)
  default     = []
}

# AWS Load Balancer Controller
variable "alb_controller_namespace" {
  description = "Namespace of the AWS Load Balancer Controller service account"
  type        = string
  default     = "kube-system"
}

variable "alb_controller_service_account" {
  description = "Name of the AWS Load Balancer Controller service account"
  type        = string
  default     = "aws-load-balancer-controller"
}

# ---------------------------------------------------------------------------
# GitHub Actions OIDC
# ---------------------------------------------------------------------------

variable "enable_github_actions_role" {
  description = "Create the GitHub Actions OIDC role"
  type        = bool
  default     = true
}

variable "create_github_oidc_provider" {
  description = "Create the GitHub OIDC provider. Only one can exist per AWS account — set false if another env already created it."
  type        = bool
  default     = true
}

variable "github_org" {
  description = "GitHub organization that owns the CI repositories"
  type        = string
  default     = null
}

variable "github_repos" {
  description = "Repositories (within github_org) whose workflows may assume the role"
  type        = list(string)
  default     = []
}

variable "github_branches" {
  description = "Branches of github_repos allowed to assume the role"
  type        = list(string)
  default     = ["main"]
}

variable "github_oidc_subjects" {
  description = "Extra raw GitHub token subjects, e.g. \"repo:org/repo:environment:prod\""
  type        = list(string)
  default     = []
}

variable "github_actions_ecr_repository_arns" {
  description = "ECR repository ARNs GitHub Actions may push to. Defaults to every repository in this account"
  type        = list(string)
  default     = []
}

variable "github_actions_policy_arns" {
  description = "Extra managed policy ARNs to attach to the GitHub Actions role"
  type        = list(string)
  default     = []
}
