output "external_secrets_role_arn" {
  description = "IAM role ARN for External Secrets Operator (annotate its service account with this)"
  value       = one(aws_iam_role.external_secrets[*].arn)
}

output "argocd_role_arn" {
  description = "IAM role ARN for ArgoCD"
  value       = one(aws_iam_role.argocd[*].arn)
}

output "alb_controller_role_arn" {
  description = "IAM role ARN for the AWS Load Balancer Controller"
  value       = one(aws_iam_role.alb_controller[*].arn)
}

output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions (use in aws-actions/configure-aws-credentials)"
  value       = one(aws_iam_role.github_actions[*].arn)
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = var.enable_github_actions_role ? local.github_oidc_provider_arn : null
}
