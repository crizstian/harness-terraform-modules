# Outputs
locals {
  git_connectors_output = merge(
    { for name, details in var.harness_platform_git_connectors : name =>
      {
        identifier = details.id
      } if !details.enable && can(details.id)
    },
    { for key, value in harness_platform_connector_git.connector : key =>
      {
        identifier = value.project_id != "" ? value.identifier : value.org_id != "" ? "org.${value.identifier}" : "account.${value.identifier}"
      }
    }
  )
  gitlab_connectors_output = merge(
    { for name, details in var.harness_platform_gitlab_connectors : name =>
      {
        identifier = details.id
      } if !details.enable && can(details.id)
    },
    { for key, value in harness_platform_connector_gitlab.connector : key =>
      {
        identifier = value.project_id != "" ? value.identifier : value.org_id != "" ? "org.${value.identifier}" : "account.${value.identifier}"
      }
    }
  )
  artifactory_connectors_output = merge(
    { for name, details in var.harness_platform_artifactory_connectors : name =>
      {
        identifier = details.id
      } if !details.enable && can(details.id)
    },
    { for key, value in harness_platform_connector_artifactory.connector : key =>
      {
        identifier = value.project_id != "" ? value.identifier : value.org_id != "" ? "org.${value.identifier}" : "account.${value.identifier}"
      }
    }
  )
  github_connectors_output = merge(
    { for name, details in var.harness_platform_github_connectors : name =>
      {
        identifier = details.id
      } if !details.enable && can(details.id)
    },
    { for key, value in harness_platform_connector_github.connector : key =>
      {
        identifier = value.project_id != "" ? value.identifier : value.org_id != "" ? "org.${value.identifier}" : "account.${value.identifier}"
      }
    },
    { for key, value in harness_platform_connector_github.connector_ssh : key =>
      {
        identifier = value.project_id != "" ? value.identifier : value.org_id != "" ? "org.${value.identifier}" : "account.${value.identifier}"
      }
    }
  )
  docker_connectors_output = merge(
    { for name, details in var.harness_platform_docker_connectors : name =>
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
  gcp_connectors_output = { for key, value in harness_platform_connector_gcp.connector : key =>
    {
      identifier = value.project_id != "" ? value.identifier : value.org_id != "" ? "org.${value.identifier}" : "account.${value.identifier}"
    }
  }
  nexus_connectors_output = { for key, value in harness_platform_connector_nexus.connector : key =>
    {
      identifier = value.project_id != "" ? value.identifier : value.org_id != "" ? "org.${value.identifier}" : "account.${value.identifier}"
    }
  }
  service_now_connectors_output = { for key, value in harness_platform_connector_service_now.connector : key =>
    {
      identifier = value.project_id != "" ? value.identifier : value.org_id != "" ? "org.${value.identifier}" : "account.${value.identifier}"
    }
  }
  dynatrace_connectors_output = { for key, value in harness_platform_connector_dynatrace.connector : key =>
    {
      identifier = value.project_id != "" ? value.identifier : value.org_id != "" ? "org.${value.identifier}" : "account.${value.identifier}"
    }
  }
  kubernetes_connectors_output = { for key, value in harness_platform_connector_kubernetes.connector : key =>
    {
      identifier         = value.project_id != "" ? value.identifier : value.org_id != "" ? "org.${value.identifier}" : "account.${value.identifier}"
      tags               = value.tags
      environment        = try(var.harness_platform_kubernetes_connectors[key].environment, "NOT_DEFINED")
      delegate_selectors = can(var.harness_platform_kubernetes_connectors[key].inherit_from_delegate) ? var.harness_platform_kubernetes_connectors[key].inherit_from_delegate.delegate_selectors : try(value.delegate_selectors, [])
    }
  }
  aws_connectors_output = { for key, value in harness_platform_connector_aws.connector : key =>
    {
      identifier = value.project_id != "" ? value.identifier : value.org_id != "" ? "org.${value.identifier}" : "account.${value.identifier}"
    }
  }
  helm_connectors_output = { for key, value in harness_platform_connector_helm.connector : key =>
    {
      identifier = value.project_id != "" ? value.identifier : value.org_id != "" ? "org.${value.identifier}" : "account.${value.identifier}"
    }
  }
  kubernetes_ccm_connectors_output = { for key, value in harness_platform_connector_kubernetes_cloud_cost.connector : key =>
    {
      identifier = value.project_id != "" ? value.identifier : value.org_id != "" ? "org.${value.identifier}" : "account.${value.identifier}"
    }
  }
}

output "all" {
  value = merge(
    length(keys(local.git_connectors_output)) > 0 ? { git_connectors = local.git_connectors_output } : {},
    length(keys(local.gitlab_connectors_output)) > 0 ? { gitlab_connectors = local.gitlab_connectors_output } : {},
    length(keys(local.artifactory_connectors_output)) > 0 ? { artifactory_connectors = local.artifactory_connectors_output } : {},
    length(keys(local.github_connectors_output)) > 0 ? { github_connectors = local.github_connectors_output } : {},
    length(keys(local.docker_connectors_output)) > 0 ? { docker_connectors = local.docker_connectors_output } : {},
    length(keys(local.gcp_connectors_output)) > 0 ? { gcp_connectors = local.gcp_connectors_output } : {},
    length(keys(local.nexus_connectors_output)) > 0 ? { nexus_connectors = local.nexus_connectors_output } : {},
    length(keys(local.service_now_connectors_output)) > 0 ? { service_now_connectors = local.service_now_connectors_output } : {},
    length(keys(local.dynatrace_connectors_output)) > 0 ? { dynatrace_connectors = local.dynatrace_connectors_output } : {},
    length(keys(local.kubernetes_connectors_output)) > 0 ? { kubernetes_connectors = local.kubernetes_connectors_output } : {},
    length(keys(local.aws_connectors_output)) > 0 ? { aws_connectors = local.aws_connectors_output } : {},
    length(keys(local.helm_connectors_output)) > 0 ? { helm_connectors = local.helm_connectors_output } : {},
    length(keys(local.kubernetes_ccm_connectors_output)) > 0 ? { kubernetes_ccm_connectors = local.kubernetes_ccm_connectors_output } : {}
  )
}
