resource "harness_platform_service" "service" {
  count       = var.enable_delegate_init_service ? 1 : 0
  identifier  = "delegate_${var.suffix}"
  name        = "delegate"
  org_id      = local.harness_organization_id
  project_id  = local.harness_organization_project_id
  description = "Install packages to the delegate selected; Service registred by terraform harness provider"
}

resource "harness_platform_environment" "environment" {
  count       = var.enable_delegate_init_service ? 1 : 0
  identifier  = "harness_${var.suffix}"
  name        = "harness"
  type        = "PreProduction"
  org_id      = local.harness_organization_id
  project_id  = local.harness_organization_project_id
  description = "Environment registred by terraform harness provider"
}
