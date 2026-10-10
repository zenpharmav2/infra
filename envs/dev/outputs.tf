output "vpc_id" {
  value = module.vpc.vpc_id
}

output "external_secrets_role_arn" {
  value = module.iam.external_secrets_role_arn
}

output "argocd_role_arn" {
  value = module.iam.argocd_role_arn
}

output "alb_controller_role_arn" {
  value = module.iam.alb_controller_role_arn
}

output "github_actions_role_arn" {
  value = module.iam.github_actions_role_arn
}
