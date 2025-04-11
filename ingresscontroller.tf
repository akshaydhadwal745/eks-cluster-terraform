resource "helm_release" "nginx_ingress" {
  depends_on = [
    helm_release.aws_load_balancer_controller
  ]
  name       = "ingress-nginx"
  namespace  = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.10.0" # check for latest stable version

  create_namespace = true

  set {
    name  = "controller.publishService.enabled"
    value = "true"
  }

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
}
