variable "harness_platform_github_connectors" {
  default = {}
}
variable "harness_platform_docker_connectors" {
  default = {}
}
variable "harness_platform_k8s_connectors" {
  default = {}
}
variable "harness_platform_aws_connectors" {
  default = {}
}

variable "suffix" {}

locals {
  aws_connectors = { for name, details in var.harness_platform_aws_connectors : "${name}_aws_connector" => merge(
    details,
    {
      identifier = "${lower(replace(name, "/[\\s-.]/", "_"))}_aws_connector_${var.suffix}"
      org_id     = try(details.org_id, "")
      project_id = try(details.project_id, "")
  }) if details.enable }

  github_connectors = { for name, details in var.harness_platform_github_connectors : "${name}_github_connector" => merge(
    details,
    {
      identifier      = "${lower(replace(name, "/[\\s-.]/", "_"))}_github_connector_${var.suffix}"
      validation_repo = details.connection_type == "Repo" ? "" : details.validation_repo
      org_id          = details.connection_type == "Repo" ? details.org_id : try(details.org_id, "")
      project_id      = details.connection_type == "Repo" ? details.project_id : try(details.project_id, "")
      credentials = {
        http = {
          username     = details.credentials.http.username
          token_ref_id = try(details.credentials.http.token_ref_id, "")
        }
      }
      api_authentication = {
        token_ref = try(details.credentials.http.token_ref_id, "")
      }
  }) if details.enable }

  github_connectors_id = { for name, details in var.harness_platform_github_connectors : "${name}_github_connector" => { identifier = details.id } if !details.enable }

  docker_connectors = { for name, details in var.harness_platform_docker_connectors : "${name}_docker_connector" => merge(
    details,
    {
      identifier = "${lower(replace(name, "/[\\s-.]/", "_"))}_docker_connector_${var.suffix}"
      org_id     = try(details.org_id, "")
      project_id = try(details.project_id, "")
      credentials = {
        username        = details.credentials.username
        password_ref_id = try(details.credentials.password_ref_id, "")
      }
  }) if details.enable }

  k8s_connectors = { for name, details in var.harness_platform_k8s_connectors : "${name}_k8s_connector" => merge(
    details,
    {
      identifier = "${lower(replace(name, "/[\\s-.]/", "_"))}_k8s_connector_${var.suffix}"
      org_id     = try(details.org_id, "")
      project_id = try(details.project_id, "")
  }) if details.enable }

  github_secrets = { for name, details in var.harness_platform_github_connectors : "${name}_github_connector_secret" => {
    secret      = details.credentials.http.token_ref
    description = details.description
    org_id      = try(details.org_id, "")
    project_id  = try(details.project_id, "")
  } if details.enable && !can(details.credentials.http.token_ref_id) }

  # docker_secrets = { for name, details in var.harness_platform_docker_connectors : "${name}_docker_connector_secret" => {
  #   secret      = details.credentials.password_ref
  #   description = details.description
  #   org_id      = try(details.org_id, "")
  #   project_id  = try(details.project_id, "")
  # } if details.enable }

  secrets = merge(
    local.github_secrets,
    # local.docker_secrets
  )
}
