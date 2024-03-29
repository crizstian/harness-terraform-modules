# github connectors
locals {

  all_connectors = merge(
    { for name, details in var.harness_platform_docker_connectors : "docker_${name}" => details },
    { for name, details in var.harness_platform_git_connectors : "git_${name}" => details },
    { for name, details in var.harness_platform_gitlab_connectors : "gitlab_${name}" => details },
    { for name, details in var.harness_platform_github_connectors : "github_${name}" => details },
    { for name, details in var.harness_platform_artifactory_connectors : "artifactory_${name}" => details },
    { for name, details in var.harness_platform_gcp_connectors : "gcp_${name}" => details },
    { for name, details in var.harness_platform_aws_connectors : "aws_${name}" => details },
    { for name, details in var.harness_platform_nexus_connectors : "nexus_${name}" => details },
    { for name, details in var.harness_platform_service_now_connectors : "service_now_${name}" => details },
    { for name, details in var.harness_platform_dynatrace_connectors : "dynatrace_${name}" => details },
    { for name, details in var.harness_platform_kubernetes_connectors : "kubernetes_${name}" => details },
    { for name, details in var.harness_platform_newrelic_connectors : "newrelic_${name}" => details },
    { for name, details in var.harness_platform_helm_connectors : "helm_${name}" => details },
  )

  connector_org_id = merge([for connector, values in local.all_connectors : { for org, details in var.organizations : connector => details.identifier if lower(org) == lower(try(values.organization, "")) }]...)
  connector_prj_id = merge([for connector, values in local.all_connectors : { for prj, details in var.projects : connector => details.identifier if lower(prj) == lower(try(values.project, "")) }]...)

  docker_connectors = { for name, details in var.harness_platform_docker_connectors : name => merge(
    details,
    {
      delegate_selectors = try(details.delegate_selectors, var.delegate_selectors)
      identifier         = "${lower(replace(name, "/[\\s-.]/", "_"))}_docker_connector_${var.suffix}"
      tags               = concat(try(details.tags, []), var.tags)
      org_id             = try(local.connector_org_id["docker_${name}"], "") != "" ? local.connector_org_id["docker_${name}"] : try(details.org_id, var.common_values.org_id)
      project_id         = try(local.connector_prj_id["docker_${name}"], "") != "" ? local.connector_prj_id["docker_${name}"] : try(details.project_id, var.common_values.project_id)
      credentials = can(details.credentials) ? {
        token = {
          username        = details.credentials.username
          password_ref_id = details.credentials.password_ref_id
        }
      } : {}
    }
  ) if details.enable }

  helm_connectors = { for name, details in var.harness_platform_helm_connectors : name => merge(
    details,
    {
      delegate_selectors = try(details.delegate_selectors, var.delegate_selectors)
      identifier         = "${lower(replace(name, "/[\\s-.]/", "_"))}_helm_connector_${var.suffix}"
      tags               = concat(try(details.tags, []), var.tags)
      org_id             = try(local.connector_org_id["helm_${name}"], "") != "" ? local.connector_org_id["helm_${name}"] : try(details.org_id, var.common_values.org_id)
      project_id         = try(local.connector_prj_id["helm_${name}"], "") != "" ? local.connector_prj_id["helm_${name}"] : try(details.project_id, var.common_values.project_id)
      credentials = can(details.credentials) ? {
        token = {
          username        = details.credentials.username
          password_ref_id = details.credentials.password_ref_id
        }
      } : {}
    }
  ) if details.enable }

  git_connectors = { for name, details in var.harness_platform_git_connectors : name => merge(
    details,
    {
      delegate_selectors = try(details.delegate_selectors, var.delegate_selectors)
      identifier         = "${lower(replace(name, "/[\\s-.]/", "_"))}_git_connector_${var.suffix}"
      validation_repo    = details.validation_repo
      tags               = concat(try(details.tags, []), var.tags)
      org_id             = try(local.connector_org_id["gitlab_${name}"], "") != "" ? local.connector_org_id["gitlab_${name}"] : try(details.org_id, var.common_values.org_id)
      project_id         = try(local.connector_prj_id["gitlab_${name}"], "") != "" ? local.connector_prj_id["gitlab_${name}"] : try(details.project_id, var.common_values.project_id)
    }
  ) if details.enable }

  gitlab_connectors = { for name, details in var.harness_platform_gitlab_connectors : name => merge(
    details,
    {
      delegate_selectors = try(details.delegate_selectors, var.delegate_selectors)
      identifier         = "${lower(replace(name, "/[\\s-.]/", "_"))}_gitlab_connector_${var.suffix}"
      validation_repo    = details.connection_type == "Repo" ? "" : details.validation_repo
      tags               = concat(try(details.tags, []), var.tags)
      org_id             = try(local.connector_org_id["gitlab_${name}"], "") != "" ? local.connector_org_id["gitlab_${name}"] : try(details.org_id, var.common_values.org_id)
      project_id         = try(local.connector_prj_id["gitlab_${name}"], "") != "" ? local.connector_prj_id["gitlab_${name}"] : try(details.project_id, var.common_values.project_id)
    }
  ) if details.enable }

  github_connectors = { for name, details in var.harness_platform_github_connectors : name => merge(
    details,
    {
      delegate_selectors = try(details.delegate_selectors, var.delegate_selectors)
      identifier         = "${lower(replace(name, "/[\\s-.]/", "_"))}_github_connector_${var.suffix}"
      validation_repo    = details.connection_type == "Repo" ? "" : details.validation_repo
      tags               = concat(try(details.tags, []), var.tags)
      org_id             = try(local.connector_org_id["github_${name}"], "") != "" ? local.connector_org_id["github_${name}"] : try(details.org_id, var.common_values.org_id)
      project_id         = try(local.connector_prj_id["github_${name}"], "") != "" ? local.connector_prj_id["github_${name}"] : try(details.project_id, var.common_values.project_id)
      api_authentication = can(details.api_authentication) ? {
        token = {
          token_ref_id = try(details.api_authentication.token_ref_id, "")
        }
      } : {}
    }
  ) if details.enable && keys(details.credentials)[0] == "http" }

  github_connectors_ssh = { for name, details in var.harness_platform_github_connectors : name => merge(
    details,
    {
      delegate_selectors = try(details.delegate_selectors, var.delegate_selectors)
      identifier         = "${lower(replace(name, "/[\\s-.]/", "_"))}_github_connector_${var.suffix}"
      validation_repo    = details.connection_type == "Repo" ? "" : details.validation_repo
      tags               = concat(try(details.tags, []), var.tags)
      org_id             = try(local.connector_org_id["github_${name}"], "") != "" ? local.connector_org_id["github_${name}"] : try(details.org_id, var.common_values.org_id)
      project_id         = try(local.connector_prj_id["github_${name}"], "") != "" ? local.connector_prj_id["github_${name}"] : try(details.project_id, var.common_values.project_id)
      api_authentication = can(details.api_authentication) ? {
        token = {
          token_ref_id = try(details.api_authentication.token_ref_id, "")
        }
      } : {}
    }
  ) if details.enable && keys(details.credentials)[0] == "ssh" }

  artifactory_connectors = { for name, details in var.harness_platform_artifactory_connectors : name => merge(
    details,
    {
      delegate_selectors = try(details.delegate_selectors, var.delegate_selectors)
      identifier         = "${lower(replace(name, "/[\\s-.]/", "_"))}_artifactory_connector_${var.suffix}"
      tags               = concat(try(details.tags, []), var.tags)
      org_id             = try(local.connector_org_id["artifactory_${name}"], "") != "" ? local.connector_org_id["artifactory_${name}"] : try(details.org_id, var.common_values.org_id)
      project_id         = try(local.connector_prj_id["artifactory_${name}"], "") != "" ? local.connector_prj_id["artifactory_${name}"] : try(details.project_id, var.common_values.project_id)
    }
  ) if details.enable }

  gcp_connectors = { for name, details in var.harness_platform_gcp_connectors : name => merge(
    details,
    {
      delegate_selectors = try(details.delegate_selectors, var.delegate_selectors)
      tags               = concat(try(details.tags, []), var.tags)
      identifier         = "${lower(replace(name, "/[\\s-.]/", "_"))}_gcp_connector_${var.suffix}"
      org_id             = try(local.connector_org_id["gcp_${name}"], "") != "" ? local.connector_org_id["gcp_${name}"] : try(details.org_id, var.common_values.org_id)
      project_id         = try(local.connector_prj_id["gcp_${name}"], "") != "" ? local.connector_prj_id["gcp_${name}"] : try(details.project_id, var.common_values.project_id)
      manual             = try(details.manual, {})
      inherit_from_delegate = can(details.inherit_from_delegate) ? {
        selectors = {
          delegate_selectors = details.inherit_from_delegate.delegate_selectors
        }
      } : {}
  }) if details.enable }

  aws_connectors = { for name, details in var.harness_platform_aws_connectors : name => merge(
    details,
    {
      delegate_selectors = try(details.delegate_selectors, var.delegate_selectors)
      tags               = concat(try(details.tags, []), var.tags)
      identifier         = "${lower(replace(name, "/[\\s-.]/", "_"))}_aws_connector_${var.suffix}"
      org_id             = try(local.connector_org_id["aws_${name}"], "") != "" ? local.connector_org_id["aws_${name}"] : try(details.org_id, var.common_values.org_id)
      project_id         = try(local.connector_prj_id["aws_${name}"], "") != "" ? local.connector_prj_id["aws_${name}"] : try(details.project_id, var.common_values.project_id)
      manual             = try(details.manual, {})
      inherit_from_delegate = can(details.inherit_from_delegate) ? {
        selectors = {
          delegate_selectors = details.inherit_from_delegate.delegate_selectors
        }
      } : {}
  }) if details.enable }

  nexus_connectors = { for name, details in var.harness_platform_nexus_connectors : name => merge(
    details,
    {
      delegate_selectors = try(details.delegate_selectors, var.delegate_selectors)
      tags               = concat(try(details.tags, []), var.tags)
      identifier         = "${lower(replace(name, "/[\\s-.]/", "_"))}_nexus_connector_${var.suffix}"
      org_id             = try(local.connector_org_id["nexus_${name}"], "") != "" ? local.connector_org_id["nexus_${name}"] : try(details.org_id, var.common_values.org_id)
      project_id         = try(local.connector_prj_id["nexus_${name}"], "") != "" ? local.connector_prj_id["nexus_${name}"] : try(details.project_id, var.common_values.project_id)
      credentials        = try(details.credentials, {})
  }) if details.enable }

  service_now_connectors = { for name, details in var.harness_platform_service_now_connectors : name => merge(
    details,
    {
      delegate_selectors = try(details.delegate_selectors, var.delegate_selectors)
      tags               = concat(try(details.tags, []), var.tags)
      identifier         = "${lower(replace(name, "/[\\s-.]/", "_"))}_service_now_connector_${var.suffix}"
      org_id             = try(local.connector_org_id["service_now_${name}"], "") != "" ? local.connector_org_id["service_now_${name}"] : try(details.org_id, var.common_values.org_id)
      project_id         = try(local.connector_prj_id["service_now_${name}"], "") != "" ? local.connector_prj_id["service_now_${name}"] : try(details.project_id, var.common_values.project_id)
  }) if details.enable }

  newrelic_connectors = { for name, details in var.harness_platform_newrelic_connectors : name => merge(
    details,
    {
      delegate_selectors = try(details.delegate_selectors, var.delegate_selectors)
      tags               = concat(try(details.tags, []), var.tags)
      identifier         = "${lower(replace(name, "/[\\s-.]/", "_"))}_newrelic_connector_${var.suffix}"
      org_id             = try(local.connector_org_id["newrelic_${name}"], "") != "" ? local.connector_org_id["newrelic_${name}"] : try(details.org_id, var.common_values.org_id)
      project_id         = try(local.connector_prj_id["newrelic_${name}"], "") != "" ? local.connector_prj_id["newrelic_${name}"] : try(details.project_id, var.common_values.project_id)
  }) if details.enable }

  dynatrace_connectors = { for name, details in var.harness_platform_dynatrace_connectors : name => merge(
    details,
    {
      delegate_selectors = try(details.delegate_selectors, var.delegate_selectors)
      tags               = concat(try(details.tags, []), var.tags)
      identifier         = "${lower(replace(name, "/[\\s-.]/", "_"))}_dynatrace_connector_${var.suffix}"
      org_id             = try(local.connector_org_id["dynatrace_${name}"], "") != "" ? local.connector_org_id["dynatrace_${name}"] : try(details.org_id, var.common_values.org_id)
      project_id         = try(local.connector_prj_id["dynatrace_${name}"], "") != "" ? local.connector_prj_id["dynatrace_${name}"] : try(details.project_id, var.common_values.project_id)
  }) if details.enable }

  kubernetes_connectors = { for name, details in var.harness_platform_kubernetes_connectors : name => merge(
    details,
    {
      delegate_selectors = can(details.inherit_from_delegate) ? null : try(details.delegate_selectors, var.delegate_selectors)
      tags               = concat(try(details.tags, []), var.tags)
      identifier         = "${lower(replace(name, "/[\\s-.]/", "_"))}_kubernetes_connector_${var.suffix}"
      org_id             = try(local.connector_org_id["kubernetes_${name}"], "") != "" ? local.connector_org_id["kubernetes_${name}"] : try(details.org_id, var.common_values.org_id)
      project_id         = try(local.connector_prj_id["kubernetes_${name}"], "") != "" ? local.connector_prj_id["kubernetes_${name}"] : try(details.project_id, var.common_values.project_id)
      service_account    = try(details.service_account, {})
      username_password  = try(details.username_password, {})
      inherit_from_delegate = can(details.inherit_from_delegate) ? {
        selectors = {
          delegate_selectors = details.inherit_from_delegate.delegate_selectors
        }
      } : {}
  }) if details.enable }

  kubernetes_ccm_connectors = { for name, details in var.harness_platform_kubernetes_ccm_connectors : name => merge(
    details,
    {
      delegate_selectors = can(details.inherit_from_delegate) ? null : try(details.delegate_selectors, var.delegate_selectors)
      tags               = concat(try(details.tags, []), var.tags)
      identifier         = "${lower(replace(name, "/[\\s-.]/", "_"))}_cloud_cost_connector_${var.suffix}"
      org_id             = "" # support only for account level
      project_id         = "" # support only for account level
      features_enabled   = try(details.features_enabled, ["VISIBILITY"])
      connector_ref      = harness_platform_connector_kubernetes.connector[name].identifier
  }) if details.enable_ccm_connector }
}
