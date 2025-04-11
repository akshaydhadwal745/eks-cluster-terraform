resource "aws_iam_policy" "external_dns" {
  name        = "ExternalDNSPolicy"
  description = "Permissions for ExternalDNS to manage Route53 records"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "route53:ChangeResourceRecordSets",
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ],
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role" "external_dns" {
  name = "external-dns-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:external-dns"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "external_dns_attach" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}

resource "kubernetes_service_account" "external_dns" {
  metadata {
    name      = "external-dns"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external_dns.arn
    }
  }
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns"
  chart      = "external-dns"
  namespace  = "kube-system"
  version    = "1.13.1" # Use latest if needed

  values = [
    yamlencode({
      provider        = "aws"
      policy          = "sync"
      zoneType        = "public"
      txtOwnerId      = aws_eks_cluster.eks.name
      domainFilters   = ["chandigarhtourism.site"] # CHANGE THIS
      serviceAccount  = {
        create = false
        name   = kubernetes_service_account.external_dns.metadata[0].name
      }
      sources         = ["ingress", "service"]
    })
  ]
   depends_on = [
    kubernetes_service_account.external_dns,
    aws_iam_role_policy_attachment.external_dns_attach,
    helm_release.aws_load_balancer_controller  # Assuming you use helm for ALB controller
  ]
}
