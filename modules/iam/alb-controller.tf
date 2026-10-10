# AWS Load Balancer Controller — manage ALBs/NLBs from Kubernetes.
# Policy is the official one from kubernetes-sigs/aws-load-balancer-controller
# (docs/install/iam_policy.json). Refresh it when upgrading the controller.

resource "aws_iam_policy" "alb_controller" {
  count = var.enable_irsa_roles ? 1 : 0

  name        = "${local.name_prefix}-alb-controller-policy"
  description = "Permissions for the AWS Load Balancer Controller"
  policy      = file("${path.module}/policies/aws-load-balancer-controller.json")
  tags        = local.tags
}

resource "aws_iam_role" "alb_controller" {
  count = var.enable_irsa_roles ? 1 : 0

  name               = "${local.name_prefix}-alb-controller-role"
  description        = "IRSA role for the AWS Load Balancer Controller"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume["alb_controller"].json
  tags               = merge(local.tags, { Name = "${local.name_prefix}-alb-controller-role" })
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  count = var.enable_irsa_roles ? 1 : 0

  role       = aws_iam_role.alb_controller[0].name
  policy_arn = aws_iam_policy.alb_controller[0].arn
}
