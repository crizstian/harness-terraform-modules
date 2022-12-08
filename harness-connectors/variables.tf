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
variable "harness_platform_gcp_connectors" {
  default = {}
}
variable "suffix" {}
variable "org_id" {
  default = "default"
}
variable "project_id" {
  default = ""
}
variable "tags" {
  default = ""
}


# github connectors
locals {
  github_connectors = { for name, details in var.harness_platform_github_connectors : name => merge(
    details,
    {
      tags            = concat(try(details.tags, []), var.tags)
      identifier      = "${lower(replace(name, "/[\\s-.]/", "_"))}_github_connector_${var.suffix}"
      validation_repo = details.connection_type == "Repo" ? "" : details.validation_repo
      org_id          = details.connection_type == "Repo" ? details.org_id : var.org_id
      project_id      = details.connection_type == "Repo" ? details.project_id : var.project_id
    }
  ) if details.enable }

  aws_connectors = { for name, details in var.harness_platform_aws_connectors : name => merge(
    details,
    {
      tags       = concat(try(details.tags, []), var.tags)
      identifier = "${lower(replace(name, "/[\\s-.]/", "_"))}_aws_connector_${var.suffix}"
      org_id     = try(details.org_id, var.org_id)
      project_id = try(details.project_id, var.project_id)
  }) if details.enable }

  gcp_connectors = { for name, details in var.harness_platform_gcp_connectors : name => merge(
    details,
    {
      tags       = concat(try(details.tags, []), var.tags)
      identifier = "${lower(replace(name, "/[\\s-.]/", "_"))}_gcp_connector_${var.suffix}"
      org_id     = try(details.org_id, var.org_id)
      project_id = try(details.project_id, var.project_id)
  }) if details.enable }

  docker_connectors = { for name, details in var.harness_platform_docker_connectors : name => merge(
    details,
    {
      tags       = concat(try(details.tags, []), var.tags)
      identifier = "${lower(replace(name, "/[\\s-.]/", "_"))}_docker_connector_${var.suffix}"
      org_id     = try(details.org_id, var.org_id)
      project_id = try(details.project_id, var.project_id)
  }) if details.enable }

  k8s_connectors = { for name, details in var.harness_platform_k8s_connectors : name => merge(
    details,
    {
      description        = "K8s Connector generated by terraform harness provider"
      delegate_selectors = [name]
      tags               = concat(try(details.tags, []), var.tags)
      identifier         = "${lower(replace(name, "/[\\s-.]/", "_"))}_k8s_connector_${var.suffix}"
      org_id             = try(details.org_id, var.org_id)
      project_id         = try(details.project_id, var.project_id)
  }) if details.enable }

  # github_secrets = { for name, details in var.harness_platform_github_connectors : "${name}_github_connector_secret" => {
  #   secret      = details.credentials.http.token_ref
  #   description = details.description
  #   org_id      = try(details.org_id, var.org_id)
  #   project_id  = try(details.project_id, var.project_id)
  # } if details.enable && !can(details.credentials.http.token_ref_id) }

  # docker_secrets = { for name, details in var.harness_platform_docker_connectors : "${name}_docker_connector_secret" => {
  #   secret      = details.credentials.password_ref
  #   description = details.description
  #   org_id      = try(details.org_id, var.org_id)
  #   project_id  = try(details.project_id, var.project_id)
  # } if details.enable }

  # secrets = merge(
  #   local.github_secrets,
  #   # local.docker_secrets
  # )
}
