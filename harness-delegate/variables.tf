variable "harness_platform_api_key" {}
variable "harness_platform_delegates" {}

variable "harness_api_endpoint" {
  default = "https://app.harness.io/gateway/ng/api"
}
variable "delegate_manifest" {
  default = "harness-delegate.yml"
}

locals {
  harness_download_k8s_delegate_endpoint    = "${var.harness_api_endpoint}/download-delegates/kubernetes"
  harness_download_docker_delegate_endpoint = "${var.harness_api_endpoint}/download-delegates/docker"

  docker_delegates = { for name, delegate in try(var.harness_platform_delegates.docker, {}) : name => {
    docker_manifest = "${name}-${var.delegate_manifest}"
    remote          = try(delegate.remote, {})
    org_id          = delegate.org_id
    body = jsonencode({
      name                   = name
      description            = delegate.description
      size                   = delegate.size
      tags                   = delegate.tags
      tokenName              = can(delegate.tokenName) ? delegate.tokenName : "default_token_${delegate.org_id}"
      clusterPermissionType  = delegate.clusterPermissionType
      customClusterNamespace = delegate.customClusterNamespace
    })
  } if delegate.enable }

  local_docker_delegates       = { for name, delegate in local.docker_delegates : name => delegate if !can(delegate.remote.host) }
  remote_docker_delegates      = { for name, delegate in local.docker_delegates : name => delegate if can(delegate.remote.host) }
  anka_remote_docker_delegates = { for name, delegate in local.remote_docker_delegates : name => delegate if delegate.remote.type == "anka" }

  k8s_delegates = { for name, delegate in try(var.harness_platform_delegates.k8s, {}) : name => {
    k8s_manifest = "${name}-${var.delegate_manifest}"
    org_id       = delegate.org_id
    body = jsonencode({
      name                   = name
      description            = delegate.description
      size                   = delegate.size
      tags                   = delegate.tags
      tokenName              = can(delegate.tokenName) ? delegate.tokenName : "default_token_${delegate.org_id}"
      clusterPermissionType  = delegate.clusterPermissionType
      customClusterNamespace = delegate.customClusterNamespace
    })
  } if delegate.enable }
}

output "delegates" {
  value = concat(keys(local.k8s_delegates), keys(local.docker_delegates))
}
