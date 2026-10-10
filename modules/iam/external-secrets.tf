# External Secrets Operator — read secrets from AWS Secrets Manager

locals {
  external_secrets_arns = length(var.external_secrets_secret_arns) > 0 ? var.external_secrets_secret_arns : [
    "arn:${local.partition}:secretsmanager:*:${local.account_id}:secret:/${var.project}/*"
  ]
}

data "aws_iam_policy_document" "external_secrets" {
  count = var.enable_irsa_roles ? 1 : 0

  statement {
    sid = "ReadSecrets"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = local.external_secrets_arns
  }
}

resource "aws_iam_role" "external_secrets" {
  count = var.enable_irsa_roles ? 1 : 0

  name               = "${local.name_prefix}-eso-role"
  description        = "IRSA role for External Secrets Operator"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume["external_secrets"].json
  tags               = merge(local.tags, { Name = "${local.name_prefix}-eso-role" })
}

resource "aws_iam_policy" "external_secrets" {
  count = var.enable_irsa_roles ? 1 : 0

  name        = "${local.name_prefix}-eso-secrets-policy"
  description = "Allow External Secrets Operator to read ${var.project} secrets from AWS Secrets Manager"
  policy      = data.aws_iam_policy_document.external_secrets[0].json
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "external_secrets" {
  count = var.enable_irsa_roles ? 1 : 0

  role       = aws_iam_role.external_secrets[0].name
  policy_arn = aws_iam_policy.external_secrets[0].arn
}
