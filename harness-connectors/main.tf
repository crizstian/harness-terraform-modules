resource "random_string" "suffix" {
  count   = local.enable_suffix
  length  = 4
  special = false
  lower   = true
}

resource "harness_platform_connector_github" "connector" {
  for_each        = local.github_connectors
  identifier      = "${lower(replace(each.key, "/[\\s-.]/", "_"))}_${local.suffix}"
  name            = each.key
  description     = each.value.description
  url             = each.value.url
  connection_type = each.value.connection_type
  validation_repo = each.value.validation_repo
  org_id          = each.value.org_id
  project_id      = each.value.project_id

  credentials {
    http {
      username  = each.value.credentials.http.username
      token_ref = each.value.credentials.http.token_ref_id != "" ? each.value.project_id != "" ? each.value.credentials.http.token_ref_id : each.value.org_id != "" ? "org.${each.value.credentials.http.token_ref_id}" : "account.${each.value.credentials.http.token_ref_id}" : harness_platform_secret_text.harness_secrets["${each.key}_secret"].id
    }
  }
  api_authentication {
    token_ref = each.value.credentials.http.token_ref_id != "" ? each.value.project_id != "" ? each.value.credentials.http.token_ref_id : each.value.org_id != "" ? "org.${each.value.credentials.http.token_ref_id}" : "account.${each.value.credentials.http.token_ref_id}" : harness_platform_secret_text.harness_secrets["${each.key}_secret"].id
  }
}

resource "harness_platform_connector_docker" "connector" {
  for_each           = local.docker_connectors
  identifier         = "${lower(replace(each.key, "/[\\s-.]/", "_"))}_${local.suffix}"
  name               = each.key
  description        = each.value.description
  tags               = each.value.tags
  delegate_selectors = each.value.delegate_selectors
  project_id         = each.value.project_id
  org_id             = each.value.org_id
  type               = each.value.type
  url                = each.value.url

  credentials {
    username     = each.value.credentials.username
    password_ref = each.value.credentials.http.password_ref_id != "" ? each.value.project_id != "" ? each.value.credentials.http.password_ref_id : each.value.org_id != "" ? "org.${each.value.credentials.http.password_ref_id}" : "account.${each.value.credentials.http.password_ref_id}" : harness_platform_secret_text.harness_secrets["${each.key}_secret"].id
  }
}

# resource "harness_platform_connector_artifactory" "connector" {
#   for_each           = local.artifactory_connectors
#   identifier         = "${lower(replace(name, "/[\\s-.]/", "_"))}_${local.suffix}"
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

# resource "harness_platform_connector_kubernetes" "inheritFromDelegate" {
#   for_each    = local.k8s_connectors
#   identifier  = "${lower(replace(name, "/[\\s-.]/", "_"))}_${local.suffix}"
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
    github_connectors = { for key, value in harness_platform_connector_github.connector : key => value.identifier }
    docker_connectors = { for key, value in harness_platform_connector_docker.connector : key => value.identifier }
    # k8s_connectors    = local.k8s_connectors
  }
}
