output "repository_urls" {
  description = "Map of repository name => repository URL (for docker push)"
  value       = { for name, repo in module.ecr : name => repo.repository_url }
}

output "repository_arns" {
  description = "Map of repository name => repository ARN"
  value       = { for name, repo in module.ecr : name => repo.repository_arn }
}
