resource "helm_release" "argocd" {
  depends_on = [ 
    aws_acm_certificate.cert,
    aws_eks_node_group.private_nodes,
    helm_release.aws_load_balancer_controller,
    helm_release.external_dns
  ]

  name             = "argocd"
  namespace        = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.51.6"
  create_namespace = true

  set {
    name  = "server.ingress.enabled"
    value = "true"
  }
  set {
    name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/listen-ports"
    value = "[{\"HTTPS\": 443}]"
  }
  # Disable ArgoCD's internal HTTPS redirect
  set {
    name  = "server.config.url"
    value = "https://argocd.chandigarhtourism.site"
  }

  set {
    name  = "server.config.server\\.insecure"
    value = "true"  
  }
  set {
    name  = "server.ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "alb"
  }
  set {
    name  = "server.ingress.backend.servicePort"
    value = "443"
  }
  set {
    name  = "server.extraArgs[0]"
    value = "--insecure"
  }
  set {
    name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/scheme"
    value = "internet-facing"
  }

  set {
    name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/certificate-arn"
    value = aws_acm_certificate.cert.arn
  }

  set {
    name  = "server.ingress.annotations.external-dns\\.alpha\\.kubernetes\\.io/hostname"
    value = "argocd.chandigarhtourism.site"
  }

  set {
    name  = "server.ingress.hosts[0]"
    value = "argocd.chandigarhtourism.site"
  }

  set {
    name  = "server.ingress.path"
    value = "/"
  }

  set {
    name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/target-type"
    value = "ip"
  }

  set {
    name  = "server.ingress.pathType"
    value = "Prefix"
  }
}
