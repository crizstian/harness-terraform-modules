resource "harness_platform_connector_gitlab" "connector" {
  for_each           = local.gitlab_connectors
  identifier         = each.value.identifier
  name               = each.key
  description        = each.value.description
  url                = each.value.url
  connection_type    = each.value.connection_type
  validation_repo    = each.value.validation_repo
  org_id             = each.value.org_id
  project_id         = each.value.project_id
  tags               = each.value.tags
  delegate_selectors = each.value.delegate_selectors

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

resource "harness_platform_connector_artifactory" "connector" {
  for_each           = local.artifactory_connectors
  identifier         = each.value.identifier
  name               = each.key
  description        = each.value.description
  url                = each.value.url
  org_id             = each.value.org_id
  project_id         = each.value.project_id
  tags               = each.value.tags
  delegate_selectors = each.value.delegate_selectors

  credentials {
    username     = each.value.credentials.http.username
    password_ref = each.value.credentials.http.password_ref_id
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

  dynamic "manual" {
    for_each = each.value.manual
    content {
      secret_key_ref     = manual.value.secret_key_ref
      delegate_selectors = manual.value.delegate_selectors
    }
  }

  dynamic "inherit_from_delegate" {
    for_each = each.value.inherit_from_delegate
    content {
      delegate_selectors = inherit_from_delegate.value.delegate_selectors
    }
  }
}

resource "harness_platform_connector_nexus" "connector" {
  for_each           = local.nexus_connectors
  identifier         = each.value.identifier
  name               = each.key
  description        = each.value.description
  url                = each.value.url
  org_id             = each.value.org_id
  project_id         = each.value.project_id
  tags               = each.value.tags
  delegate_selectors = each.value.delegate_selectors
  version            = each.value.version

  dynamic "credentials" {
    for_each = each.value.credentials
    content {
      username     = credentials.value.username
      password_ref = credentials.value.password_ref_id
    }
  }
}

resource "harness_platform_connector_service_now" "connector" {
  for_each           = local.service_now_connectors
  identifier         = each.value.identifier
  name               = each.key
  description        = each.value.description
  org_id             = each.value.org_id
  project_id         = each.value.project_id
  tags               = each.value.tags
  delegate_selectors = each.value.delegate_selectors
  service_now_url    = each.value.service_now_url

  auth {
    auth_type = each.value.auth.credentials.auth_type

    username_password {
      username     = each.value.auth.credentials.username
      password_ref = each.value.auth.credentials.password_ref
    }
  }
}

resource "harness_platform_connector_dynatrace" "connector" {
  for_each           = local.dynatrace_connectors
  identifier         = each.value.identifier
  name               = each.key
  description        = each.value.description
  org_id             = each.value.org_id
  project_id         = each.value.project_id
  tags               = each.value.tags
  delegate_selectors = each.value.delegate_selectors
  url                = each.value.url
  api_token_ref      = each.value.api_token_ref
}

resource "harness_platform_connector_kubernetes" "connector" {
  for_each           = local.kubernetes_connectors
  identifier         = each.value.identifier
  name               = each.key
  description        = each.value.description
  tags               = each.value.tags
  project_id         = each.value.project_id
  org_id             = each.value.org_id
  delegate_selectors = each.value.delegate_selectors

  dynamic "service_account" {
    for_each = each.value.service_account
    content {
      master_url                = service_account.value.master_url
      service_account_token_ref = service_account.value.service_account_token_ref
    }
  }

  dynamic "username_password" {
    for_each = each.value.username_password
    content {
      master_url   = username_password.value.master_url
      username     = username_password.value.username
      password_ref = username_password.value.password_ref
    }
  }

  dynamic "inherit_from_delegate" {
    for_each = each.value.inherit_from_delegate
    content {
      delegate_selectors = inherit_from_delegate.value.delegate_selectors
    }
  }
}

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
    token_ref = each.value.api_authentication.token_ref_id
  }
}
resource "harness_platform_connector_github" "connector_ssh" {
  for_each        = local.github_connectors_ssh
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
    ssh {
      ssh_key_ref = each.value.credentials.ssh.ssh_key_ref_id
    }
  }
  api_authentication {
    token_ref = each.value.api_authentication.token_ref_id
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

  dynamic "credentials" {
    for_each = each.value.credentials
    content {
      username     = credentials.value.username
      password_ref = credentials.value.password_ref_id
    }
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

  dynamic "manual" {
    for_each = each.value.manual
    content {
      access_key_ref     = manual.value.access_key_ref
      secret_key_ref     = manual.value.secret_key_ref
      delegate_selectors = manual.value.delegate_selectors
    }
  }
}

