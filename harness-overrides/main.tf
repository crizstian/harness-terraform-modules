resource "harness_platform_environment_service_overrides" "overrides" {
  for_each   = local.environments_service_overrides
  identifier = each.value.vars.identifier
  org_id     = each.value.vars.org_id
  env_id     = each.value.vars.env_id
  /* project_id = each.value.vars.project_id */
  service_id = each.value.vars.service_id
  yaml       = <<-EOT
          serviceOverrides:
            environmentRef: ${each.value.vars.env_id}
            serviceRef: ${each.value.vars.service_id}
            variables:    
                - name: address_public
                  type: String
                  value: bff-alvi-web.alvi.cl                
          EOT
}
