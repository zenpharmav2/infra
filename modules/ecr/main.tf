module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 3.2"

  for_each = toset(var.repositories)

  repository_name                 = each.value
  repository_image_tag_mutability = var.image_tag_mutability
  repository_image_scan_on_push   = true

  # Access is granted through IAM roles (e.g. GitHub Actions), not a repository policy
  create_repository_policy = false

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last ${var.keep_image_count} images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.keep_image_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Name    = "${var.project}-${each.value}"
    Env     = var.env
    Project = var.project
  }
}
