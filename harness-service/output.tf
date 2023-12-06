output "services" {
  value = { for key, details in harness_platform_service.services : key =>
    merge(
      local.services[key],
      {
        identifier = details.identifier
      }
    )
  }
}
