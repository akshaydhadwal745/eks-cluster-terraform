resource "helm_release" "descheduler" {
  depends_on = [ aws_eks_node_group.private_nodes ]
  name       = "descheduler"
  repository = "https://kubernetes-sigs.github.io/descheduler"
  chart      = "descheduler"
  namespace  = "kube-system"
  version    = "0.29.0" # latest as of April 2025, update if needed

  create_namespace = false

  values = [
    yamlencode({
      deschedulerPolicy = {
        strategies = {
          RemoveDuplicates = {
            enabled = true
          }
          RemovePodsHavingTooManyRestarts = {
            enabled = true
            params = {
              podsHavingTooManyRestarts = {
                podRestartThreshold = 10
                includingInitContainers = true
              }
            }
          }
          LowNodeUtilization = {
            enabled = true
            params = {
              nodeResourceUtilizationThresholds = {
                thresholds = {
                  cpu    = 20
                  memory = 20
                  pods   = 20
                }
                targetThresholds = {
                  cpu    = 50
                  memory = 50
                  pods   = 50
                }
              }
            }
          }
        }
      }

      kind = "CronJob" # You can change this to "Deployment" for continuous runs
      schedule = "*/5 * * * *" # Every 5 mins
    })
  ]
}
