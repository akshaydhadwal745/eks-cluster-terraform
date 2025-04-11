resource "aws_acm_certificate" "argocd_cert" {
  domain_name       = "argocd.chandigarhtourism.site"
  validation_method = "DNS"

  tags = {
    Name = "argocd-cert"
  }
}

resource "aws_route53_record" "argocd_cert_validation" {
  name    = element(tolist(aws_acm_certificate.argocd_cert.domain_validation_options), 0).resource_record_name
  type    = element(tolist(aws_acm_certificate.argocd_cert.domain_validation_options), 0).resource_record_type
  zone_id = "Z0960081J0UVVBH5RU5P"
  records = [element(tolist(aws_acm_certificate.argocd_cert.domain_validation_options), 0).resource_record_value]
  ttl     = 300
}

resource "aws_acm_certificate_validation" "argocd_cert" {
  certificate_arn         = aws_acm_certificate.argocd_cert.arn
  validation_record_fqdns = [aws_route53_record.argocd_cert_validation.fqdn]
}
