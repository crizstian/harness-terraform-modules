module "bootstrap_harness_connectors" {
  source                          = "../harness-connector"
  for_each                        = local.k8s_connectors
  suffix                          = var.suffix
  tags                            = var.tags
  org_id                          = each.value.org_id
  project_id                      = each.value.project_id
  harness_platform_k8s_connectors = { "${each.key}" = each.value }
}
