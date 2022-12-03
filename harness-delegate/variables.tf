variable "harness_platform_api_key" {}
variable "harness_platform_delegates" {}
variable "harness_account_id" {}
variable "harness_organization" {}
variable "suffix" {}
variable "enable_delegate_init_service" {}
variable "harness_api_endpoint" {
  default = "https://app.harness.io/gateway/ng/api"
}
variable "harness_docker_drone_runner_endpoint" {
  default = "https://github.com/harness/drone-docker-runner/releases/download/v0.1.0/drone-docker-runner-linux-amd64"
}
variable "delegate_manifest" {
  default = "harness-delegate.yml"
}
variable "delegate_schema" {
  default = {}
}

# Common Vars
locals {
  harness_organization_id         = var.harness_organization.org_id
  harness_organization_project_id = var.harness_organization.seed_project_id
  harness_filestore_api           = "${var.harness_api_endpoint}/file-store"
  account_args                    = "accountIdentifier=${var.harness_account_id}"
}

# Delegates enabled
locals {
  common_schema_delegate = length(var.delegate_schema) > 0 ? var.delegate_schema : {
    description            = "Delegate deployed and generated by terraform harness provider"
    size                   = "SMALL"
    tags                   = ["owner: ${var.organization_prefix}"]
    clusterPermissionType  = "CLUSTER_ADMIN"
    customClusterNamespace = "harness-delegate-ng"
  }

  enabled_delegates = { for type, delegates in var.harness_platform_delegates : type =>
    {
      for key, value in delegates : key => merge(value, local.common_schema_delegate) if value.enable
    }
  }
}

# Delegate Configuration
locals {
  docker_delegates = { for name, delegate in try(local.enabled_delegates.docker, {}) : name => {
    manifest          = "${name}-${var.delegate_manifest}"
    delegate_endpoint = "${var.harness_api_endpoint}/download-delegates/docker"
    url_args          = can(delegate.org_id) ? can(delegate.proj_id) ? "${local.account_args}&orgIdentifier=${delegate.org_id}&projectIdentifier=${delegate.proj_id}" : "${local.account_args}&orgIdentifier=${delegate.org_id}" : "${local.account_args}"
    tokenName         = can(delegate.tokenName) ? delegate.tokenName : can(delegate.org_id) ? "default_token_${delegate.org_id}" : "default_token"
    identifier        = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
    auto_install      = try(delegate.auto_install, false)
    connection        = try(delegate.connection, {})

    body = jsonencode({
      name                   = name
      tokenName              = can(delegate.tokenName) ? delegate.tokenName : can(delegate.org_id) ? "default_token_${delegate.org_id}" : "default_token"
      description            = delegate.description
      size                   = delegate.size
      tags                   = delegate.tags
      clusterPermissionType  = delegate.clusterPermissionType
      customClusterNamespace = delegate.customClusterNamespace
    })
  } }

  k8s_delegates = { for name, delegate in try(local.enabled_delegates.k8s, {}) : name => {
    manifest          = "${name}-${var.delegate_manifest}"
    url_args          = can(delegate.org_id) ? can(delegate.proj_id) ? "${local.account_args}&orgIdentifier=${delegate.org_id}&projectIdentifier=${delegate.proj_id}" : "${local.account_args}&orgIdentifier=${delegate.org_id}" : "${local.account_args}"
    delegate_endpoint = "${var.harness_api_endpoint}/download-delegates/kubernetes"
    tokenName         = can(delegate.tokenName) ? delegate.tokenName : can(delegate.org_id) ? "default_token_${delegate.org_id}" : "default_token"
    identifier        = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
    auto_install      = try(delegate.auto_install, false)
    connection        = try(delegate.connection, {})

    body = jsonencode({
      name                   = name
      description            = delegate.description
      size                   = delegate.size
      tags                   = delegate.tags
      tokenName              = can(delegate.tokenName) ? delegate.tokenName : can(delegate.org_id) ? "default_token_${delegate.org_id}" : "default_token"
      clusterPermissionType  = delegate.clusterPermissionType
      customClusterNamespace = delegate.customClusterNamespace
    })
  } }
}

# Delegate Setup
locals {
  install_docker_delegates = { for name, delegate in local.docker_delegates : name => delegate if delegate.auto_install && length(delegate.connection) > 0 }
  install_on_linux         = { for name, delegate in local.install_docker_delegates : name => delegate if delegate.os == "linux" }

  # install_k8s_delegates = { for name, delegate in local.k8s_delegates : name => delegate if delegate.auto_install && length(delegate.connection) > 0 }
  # remote_docker_delegates = { for name, delegate in local.docker_delegates : name => delegate if can(delegate.remote.host) }
  # anka_remote_docker_delegates = { for name, delegate in local.remote_docker_delegates : name => delegate if delegate.remote.type == "anka" }

  delegates = merge(
    local.docker_delegates,
    local.k8s_delegates
    # local.anka_remote_docker_delegates,
  )
}

