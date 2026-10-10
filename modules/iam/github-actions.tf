# GitHub Actions OIDC — CI gets short-lived credentials, no static AWS keys in GitHub.
#
# How it works:
#   1. GitHub mints a short-lived OIDC token per workflow run
#   2. The workflow calls aws-actions/configure-aws-credentials with
#      role-to-assume: <github_actions_role_arn>
#   3. AWS validates the token against the registered OIDC provider and
#      issues temporary STS credentials (valid for 1 hour max)

locals {
  github_oidc_url          = "https://token.actions.githubusercontent.com"
  github_oidc_provider_arn = "arn:${local.partition}:iam::${local.account_id}:oidc-provider/token.actions.githubusercontent.com"

  github_oidc_subjects = concat(
    [for pair in setproduct(var.github_repos, var.github_branches) : "repo:${var.github_org}/${pair[0]}:ref:refs/heads/${pair[1]}"],
    var.github_oidc_subjects,
  )

  github_actions_ecr_arns = length(var.github_actions_ecr_repository_arns) > 0 ? var.github_actions_ecr_repository_arns : [
    "arn:${local.partition}:ecr:*:${local.account_id}:repository/*"
  ]
}

resource "aws_iam_openid_connect_provider" "github" {
  count = var.enable_github_actions_role && var.create_github_oidc_provider ? 1 : 0

  url            = local.github_oidc_url
  client_id_list = ["sts.amazonaws.com"]

  # AWS no longer validates these for GitHub, but the API still accepts them
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
  ]

  tags = merge(local.tags, { Name = "github-actions-oidc-provider" })
}

data "aws_iam_policy_document" "github_actions_assume" {
  count = var.enable_github_actions_role ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.github_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Restrict which repos/branches can assume the role
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.github_oidc_subjects
    }
  }
}

resource "aws_iam_role" "github_actions" {
  count = var.enable_github_actions_role ? 1 : 0

  name                 = "${local.name_prefix}-github-actions-role"
  description          = "Assumed by GitHub Actions via OIDC"
  assume_role_policy   = data.aws_iam_policy_document.github_actions_assume[0].json
  max_session_duration = 3600
  tags                 = merge(local.tags, { Name = "${local.name_prefix}-github-actions-role" })

  depends_on = [aws_iam_openid_connect_provider.github]

  lifecycle {
    precondition {
      condition     = length(local.github_oidc_subjects) > 0
      error_message = "Set github_org + github_repos (or github_oidc_subjects), or any GitHub repo could assume this role."
    }
  }
}

data "aws_iam_policy_document" "github_actions_ci" {
  count = var.enable_github_actions_role ? 1 : 0

  statement {
    sid       = "ECRAuth"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid = "ECRPush"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = local.github_actions_ecr_arns
  }

  statement {
    sid = "EKSRead"
    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "github_actions_ci" {
  count = var.enable_github_actions_role ? 1 : 0

  name        = "${local.name_prefix}-github-actions-policy"
  description = "Allow GitHub Actions CI to push images to ECR and read EKS cluster info"
  policy      = data.aws_iam_policy_document.github_actions_ci[0].json
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "github_actions_ci" {
  count = var.enable_github_actions_role ? 1 : 0

  role       = aws_iam_role.github_actions[0].name
  policy_arn = aws_iam_policy.github_actions_ci[0].arn
}

resource "aws_iam_role_policy_attachment" "github_actions_extra" {
  for_each = var.enable_github_actions_role ? toset(var.github_actions_policy_arns) : toset([])

  role       = aws_iam_role.github_actions[0].name
  policy_arn = each.value
}
