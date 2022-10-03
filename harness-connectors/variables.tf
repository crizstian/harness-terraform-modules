variable "harness_platform_github_connectors" {
  default = ""
}
variable "harness_platform_docker_connectors" {
  default = ""
}

locals {
  github_connectors = { for name, details in var.harness_platform_github_connectors : "${name}_github_connector" => {
    description     = details.description
    connection_type = details.connection_type
    url             = details.url
    # delegate_selectors = details.delegate_selectors
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
  } if details.enable }

  # k8s_connectors = { for name, details in var.harness_connectors.k8s : "${name}_k8s_connector" => {
  #   enable             = details.enable
  #   description        = details.description
  #   tags               = details.tags
  #   delegate_selectors = details.delegate_selectors
  #   org_id             = details.org_id == "" ? var.harness_platform_project.organization_id : details.org_id
  #   project_id         = var.harness_platform_project.id
  # } if details.enable }

  docker_connectors = { for name, details in var.harness_platform_docker_connectors : "${name}_docker_connector" => {
    enable             = details.enable
    description        = details.description
    tags               = details.tags
    delegate_selectors = details.delegate_selectors
    type               = details.type
    url                = details.url
    org_id             = try(details.org_id, "")
    project_id         = try(details.project_id, "")
    credentials = {
      username = details.credentials.username
    }

  } if details.enable }

  github_secrets = { for name, details in var.harness_platform_github_connectors : "${name}_github_connector_secret" => {
    secret      = details.credentials.http.token_ref
    description = details.description
    org_id      = try(details.org_id, "")
    project_id  = try(details.project_id, "")
  } if details.enable && !can(details.credentials.http.token_ref_id) }

  docker_secrets = { for name, details in var.harness_platform_docker_connectors : "${name}_docker_connector_secret" => {
    secret      = details.credentials.password_ref
    description = details.description
    org_id      = try(details.org_id, "")
    project_id  = try(details.project_id, "")
  } if details.enable }

  secrets = merge(
    local.github_secrets,
    local.docker_secrets
  )
}
