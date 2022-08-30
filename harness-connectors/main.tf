resource "harness_platform_secret_text" "harness_secrets" {
  for_each                  = local.secrets
  identifier                = lower(replace(each.key, "/[\\s-.]/", "_"))
  name                      = each.key
  description               = each.value.description
  secret_manager_identifier = "harnessSecretManager"
  value_type                = "Inline"
  value                     = each.value.secret
  org_id                    = each.value.org_id
  project_id                = each.value.project_id

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

# resource "harness_platform_connector_artifactory" "connector" {
#   for_each           = local.artifactory_connectors
#   identifier         = lower(replace(name, "/[\\s-.]/", "_"))
#   name               = each.key
#   description        = each.value.description
#   url                = each.value.url
#   connection_type    = each.value.connection_type
#   validation_repo    = each.value.validation_repo
#   delegate_selectors = each.value.delegate_selectors
#   org_id             = each.value.org_id
#   #   project_id         = each.value.project_id
#   credentials {
#     http {
#       username     = each.value.credentials.http.username
#       password_ref = harness_platform_secret_text.harness_secrets["${each.key}_secret"].id
#     }
#   }
# }

resource "harness_platform_connector_github" "connector" {
  for_each           = local.github_connectors
  identifier         = lower(replace(each.key, "/[\\s-.]/", "_"))
  name               = each.key
  description        = each.value.description
  url                = each.value.url
  connection_type    = each.value.connection_type
  validation_repo    = each.value.validation_repo
  delegate_selectors = each.value.delegate_selectors
  org_id             = each.value.org_id
  project_id         = each.value.project_id
  credentials {
    http {
      username  = each.value.credentials.http.username
      token_ref = harness_platform_secret_text.harness_secrets["${each.key}_secret"].id
    }
  }
}

# resource "harness_platform_connector_docker" "registry" {
#   for_each           = local.docker_connectors
#   identifier         = lower(replace(name, "/[\\s-.]/", "_"))
#   name               = each.key
#   description        = each.value.description
#   tags               = each.value.tags
#   delegate_selectors = each.value.delegate_selectors
#   project_id         = each.value.project_id
#   org_id             = each.value.org_id
#   type               = each.value.type
#   url                = each.value.url

#   credentials {
#     username     = each.value.credentials.username
#     password_ref = harness_platform_secret_text.harness_secrets["${each.key}_secret"].id
#   }
# }

# resource "harness_platform_connector_kubernetes" "inheritFromDelegate" {
#   for_each    = local.k8s_connectors
#   identifier  = lower(replace(name, "/[\\s-.]/", "_"))
#   name        = each.key
#   description = each.value.description
#   tags        = each.value.tags
#   org_id      = each.value.org_id
#   project_id  = each.value.project_id

#   inherit_from_delegate {
#     delegate_selectors = each.value.delegate_selectors
#   }
# }

output "connectors" {
  value = {
    github_connectors = local.github_connectors
    # k8s_connectors    = local.k8s_connectors
    # docker_connectors = local.docker_connectors
  }
}
