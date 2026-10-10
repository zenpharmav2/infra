# ArgoCD — application controller service account.
# No AWS permissions by default (Git sync needs none); add some via argocd_policy_arns.

resource "aws_iam_role" "argocd" {
  count = var.enable_irsa_roles ? 1 : 0

  name               = "${local.name_prefix}-argocd-role"
  description        = "IRSA role for the ArgoCD application controller"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume["argocd"].json
  tags               = merge(local.tags, { Name = "${local.name_prefix}-argocd-role" })
}

resource "aws_iam_role_policy_attachment" "argocd" {
  for_each = var.enable_irsa_roles ? toset(var.argocd_policy_arns) : toset([])

  role       = aws_iam_role.argocd[0].name
  policy_arn = each.value
}
