data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  name_prefix = "${var.project}-${var.env}"
  account_id  = data.aws_caller_identity.current.account_id
  partition   = data.aws_partition.current.partition

  # The OIDC condition keys use the issuer URL without the scheme
  eks_oidc_issuer = var.eks_oidc_provider_url == null ? "" : replace(var.eks_oidc_provider_url, "https://", "")

  tags = {
    Project = var.project
    Env     = var.env
  }
}

# Shared IRSA trust policy: only the given namespace:serviceaccount pairs
# in this cluster may assume the role.
data "aws_iam_policy_document" "irsa_assume" {
  for_each = var.enable_irsa_roles ? {
    external_secrets = ["system:serviceaccount:${var.external_secrets_namespace}:${var.external_secrets_service_account}"]
    argocd           = [for sa in var.argocd_service_accounts : "system:serviceaccount:${var.argocd_namespace}:${sa}"]
    alb_controller   = ["system:serviceaccount:${var.alb_controller_namespace}:${var.alb_controller_service_account}"]
  } : {}

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.eks_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer}:sub"
      values   = each.value
    }
  }
}
