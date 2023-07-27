resource "harness_platform_service" "services" {
  for_each    = local.services
  name        = each.key
  description = each.value.vars.description
  identifier  = each.value.vars.identifier
  org_id      = each.value.vars.org_id
  project_id  = each.value.vars.project_id
  tags        = each.value.vars.tags
  yaml        = templatefile("./service.tftpl",each.value.vars)
}
