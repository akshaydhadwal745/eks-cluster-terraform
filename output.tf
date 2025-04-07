output "cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "Instance-IP" {
    value = aws_instance.main_instance.public_ip
}