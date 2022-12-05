module "bootstrap_harness_connectors" {
  source                          = "../harness-connectors"
  suffix                          = var.suffix
  org_id                          = var.harness_organization_id
  tags                            = var.tags
  harness_platform_k8s_connectors = local.k8s_connectors
}
