variable "harness_platform_api_key" {}
variable "harness_platform_delegates" {}
variable "harness_account_id" {}
variable "harness_organization_id" {}
variable "suffix" {}

variable "harness_api_endpoint" {
  default = "https://app.harness.io/gateway/ng/api"
}
variable "delegate_manifest" {
  default = "harness-delegate.yml"
}

locals {
  harness_filestore_api = "${var.harness_api_endpoint}/file-store"
  account_args          = "accountIdentifier=${var.harness_account_id}"

  docker_delegates = { for name, delegate in try(var.harness_platform_delegates.docker, {}) : name => {
    manifest          = "${name}-${var.delegate_manifest}"
    remote            = try(delegate.remote, {})
    delegate_endpoint = "${var.harness_api_endpoint}/download-delegates/docker"
    url_args          = can(delegate.org_id) ? can(delegate.proj_id) ? "${local.account_args}&orgIdentifier=${delegate.org_id}&projectIdentifier=${delegate.proj_id}" : "${local.account_args}&orgIdentifier=${delegate.org_id}" : "${local.account_args}"
    tokenName         = can(delegate.tokenName) ? delegate.tokenName : can(delegate.org_id) ? "default_token_${delegate.org_id}" : "default_token"
    identifier        = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"

    body = jsonencode({
      name                   = name
      tokenName              = can(delegate.tokenName) ? delegate.tokenName : can(delegate.org_id) ? "default_token_${delegate.org_id}" : "default_token"
      description            = delegate.description
      size                   = delegate.size
      tags                   = delegate.tags
      clusterPermissionType  = delegate.clusterPermissionType
      customClusterNamespace = delegate.customClusterNamespace
    })
  } if delegate.enable }

  k8s_delegates = { for name, delegate in try(var.harness_platform_delegates.k8s, {}) : name => {
    manifest          = "${name}-${var.delegate_manifest}"
    url_args          = can(delegate.org_id) ? can(delegate.proj_id) ? "${local.account_args}&orgIdentifier=${delegate.org_id}&projectIdentifier=${delegate.proj_id}" : "${local.account_args}&orgIdentifier=${delegate.org_id}" : "${local.account_args}"
    delegate_endpoint = "${var.harness_api_endpoint}/download-delegates/kubernetes"
    tokenName         = can(delegate.tokenName) ? delegate.tokenName : can(delegate.org_id) ? "default_token_${delegate.org_id}" : "default_token"
    identifier        = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"

    body = jsonencode({
      name                   = name
      description            = delegate.description
      size                   = delegate.size
      tags                   = delegate.tags
      tokenName              = can(delegate.tokenName) ? delegate.tokenName : can(delegate.org_id) ? "default_token_${delegate.org_id}" : "default_token"
      clusterPermissionType  = delegate.clusterPermissionType
      customClusterNamespace = delegate.customClusterNamespace
    })
  } if delegate.enable }

  local_docker_delegates       = { for name, delegate in local.docker_delegates : name => delegate if !can(delegate.remote.host) }
  remote_docker_delegates      = { for name, delegate in local.docker_delegates : name => delegate if can(delegate.remote.host) }
  anka_remote_docker_delegates = { for name, delegate in local.remote_docker_delegates : name => delegate if delegate.remote.type == "anka" }

  delegates = merge(
    local.local_docker_delegates,
    local.remote_docker_delegates,
    local.anka_remote_docker_delegates,
    local.k8s_delegates
  )
}

output "delegates" {
  value = concat(keys(local.delegates))
}

output "delegates-verbose" {
  value = local.delegates
}
