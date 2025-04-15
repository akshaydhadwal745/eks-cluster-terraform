output "cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "EKS_Auth" {
  value = "aws eks --region ap-south-1 update-kubeconfig --name EKS-test"
}
