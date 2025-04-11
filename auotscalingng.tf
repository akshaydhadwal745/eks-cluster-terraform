# Discover the ASG created by the node group
data "aws_autoscaling_groups" "eks_node_asgs" {
  filter {
    name   = "tag:eks:nodegroup-name"
    values = [aws_eks_node_group.private_nodes.node_group_name]
  }

  depends_on = [aws_eks_node_group.private_nodes]
}

resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "eks-cpu-autoscaling"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = data.aws_autoscaling_groups.eks_node_asgs.names[0]

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }

  estimated_instance_warmup = 180

  depends_on = [data.aws_autoscaling_groups.eks_node_asgs]
}