resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.8.23" 

  create_namespace = true

  values = [
    templatefile("${path.module}/argocd-values.yaml.tpl", {
      acm_cert_arn = aws_acm_certificate_validation.argocd_cert.certificate_arn
    })
  ]
  depends_on = [ aws_eks_node_group.private_nodes,helm_release.aws_load_balancer_controller ]
}
