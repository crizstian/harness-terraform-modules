output "agent" {
  value = { for key, details in harness_platform_gitops_agent.agent : key =>
      {
        identifier = details.identifier
      }
  }
}
output "cluster" {
  value = { for key, details in harness_platform_gitops_cluster.cluster : key =>
      {
        identifier = details.identifier
      }
  }
}
output "app" {
  value = { for key, details in harness_platform_gitops_applications.app : key =>
      {
        identifier = details.identifier
      }
  }
}
