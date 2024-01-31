resource "harness_platform_service" "service" {
  count       = var.delegate_init_service.enable ? 1 : 0
  identifier  = "delegate_${var.suffix}"
  name        = "delegate"
  org_id      = var.delegate_init_service.org_id
  project_id  = var.delegate_init_service.project_id
  description = "Install packages to the delegate selected; Service registred by terraform harness provider"
}

resource "harness_platform_environment" "environment" {
  count       = var.delegate_init_service.enable ? 1 : 0
  identifier  = "harness_${var.suffix}"
  name        = "harness"
  type        = "PreProduction"
  org_id      = var.delegate_init_service.org_id
  project_id  = var.delegate_init_service.project_id
  description = "Environment registred by terraform harness provider"
}
