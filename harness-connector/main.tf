resource "harness_platform_connector_github" "connector" {
  for_each        = local.github_connectors
  identifier      = each.value.identifier
  name            = each.key
  description     = each.value.description
  url             = each.value.url
  connection_type = each.value.connection_type
  validation_repo = each.value.validation_repo
  org_id          = each.value.org_id
  project_id      = each.value.project_id
  tags            = each.value.tags

  credentials {
    http {
      username  = each.value.credentials.http.username
      token_ref = each.value.credentials.http.token_ref_id
    }
  }
  api_authentication {
    token_ref = each.value.credentials.http.token_ref_id
  }
}

resource "harness_platform_connector_docker" "connector" {
  for_each           = local.docker_connectors
  identifier         = each.value.identifier
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
    password_ref = each.value.credentials.password_ref_id
  }
}

resource "harness_platform_connector_kubernetes" "connector" {
  for_each    = local.k8s_connectors
  identifier  = each.value.identifier
  name        = each.key
  description = each.value.description
  tags        = each.value.tags
  project_id  = each.value.project_id
  org_id      = each.value.org_id

  inherit_from_delegate {
    delegate_selectors = each.value.delegate_selectors
  }

  service_account {
    master_url                = "https://kubernetes.example.com"
    service_account_token_ref = "account.TEST_k8s_client_test"
  }
  delegate_selectors = ["harness-delegate"]

  username_password {
    master_url   = "https://kubernetes.example.com"
    username     = "admin"
    password_ref = "account.TEST_k8s_client_test"
  }
}

resource "harness_platform_connector_aws" "connector" {
  for_each    = local.aws_connectors
  identifier  = each.value.identifier
  name        = each.key
  description = each.value.description
  tags        = each.value.tags
  project_id  = each.value.project_id
  org_id      = each.value.org_id

  manual {
    access_key_ref     = each.value.manual.access_key_ref
    secret_key_ref     = each.value.manual.secret_key_ref
    delegate_selectors = each.value.delegate_selectors
  }
}

resource "harness_platform_connector_gcp" "connector" {
  for_each    = local.gcp_connectors
  identifier  = each.value.identifier
  name        = each.key
  description = each.value.description
  tags        = each.value.tags
  project_id  = each.value.project_id
  org_id      = each.value.org_id

  manual {
    secret_key_ref     = each.value.manual.secret_key_ref
    delegate_selectors = each.value.delegate_selectors
  }
}

# resource "harness_platform_connector_artifactory" "connector" {
#   for_each           = local.artifactory_connectors
#   identifier         = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
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

