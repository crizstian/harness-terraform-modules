# Outputs
locals {
  github_connectors_output = merge(
    { for name, details in var.harness_platform_github_connectors : "${name}_github_connector" =>
      {
        identifier = details.id
      } if !details.enable && can(details.id)
    },
    { for key, value in harness_platform_connector_github.connector : key =>
      {
        identifier = value.project_id != "" ? value.identifier : value.org_id != "" ? "org.${value.identifier}" : "account.${value.identifier}"
      }
    }
  )
  docker_connectors_output = merge(
    { for name, details in var.harness_platform_docker_connectors : "${name}_docker_connector" =>
      {
        identifier = details.id
      } if !details.enable && can(details.id)
    },
    { for key, value in harness_platform_connector_docker.connector : key =>
      {
        identifier = value.project_id != "" ? value.identifier : value.org_id != "" ? "org.${value.identifier}" : "account.${value.identifier}"
      }
    }
  )
  k8s_connectors_output = merge(
    { for name, details in var.harness_platform_k8s_connectors : "${name}_k8s_connector" =>
      {
        identifier = details.connector_id
      } if !details.enable && can(details.connector_id)
    },
    { for key, value in harness_platform_connector_kubernetes.connector : key =>
      {
        identifier = value.project_id != "" ? value.identifier : value.org_id != "" ? "org.${value.identifier}" : "account.${value.identifier}"
      }
    }
  )
  aws_connectors_output = { for key, value in harness_platform_connector_aws.connector : key =>
    {
      identifier = value.project_id != "" ? value.identifier : value.org_id != "" ? "org.${value.identifier}" : "account.${value.identifier}"
    }
  }
  gcp_connectors_output = { for key, value in harness_platform_connector_gcp.connector : key =>
    {
      identifier = value.project_id != "" ? value.identifier : value.org_id != "" ? "org.${value.identifier}" : "account.${value.identifier}"
    }
  }
}

output "connectors" {
  value = merge(tomap(
    can(length(local.github_connectors_output) > 0) ? { github_connectors = local.github_connectors_output } : {},
    can(length(local.docker_connectors_output) > 0) ? { docker_connectors = local.docker_connectors_output } : {},
    can(length(local.aws_connectors_output) > 0) ? { aws_connectors = local.aws_connectors_output } : {},
    can(length(local.gcp_connectors_output) > 0) ? { gcp_connectors = local.gcp_connectors_output } : {},
    can(length(local.k8s_connectors_output) > 0) ? { k8s_connectors = local.k8s_connectors_output } : {}
  ))
}
