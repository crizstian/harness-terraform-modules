output "delegate_init" {
  value = {
    service_ref     = var.delegate_init_service.enable ? harness_platform_service.service[0].identifier : ""
    environment_ref = var.delegate_init_service.enable ? harness_platform_environment.environment[0].identifier : ""
  }
}

output "manifests" {
  value = {
    "${local.harness_organization_id}" = { for key, value in local.delegates : key => {
      identifier    = value.identifier
      manifest      = "${local.harness_filestore_api}/files/${value.identifier}/download?${value.url_args}"
      file_store    = "https://app.harness.io/ng/#/account/${var.harness_account_id}/settings/resources/file-store"
      k8s_connector = { identifier = try(module.bootstrap_harness_connectors[key].connectors.k8s_connectors[key].identifier, "none") }
    } }
  }
}

output "delegates-verbose" {
  value = local.delegates
}
