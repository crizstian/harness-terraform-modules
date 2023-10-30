# output "service_account_token" {
#   value = { for k, v in kubernetes_secret_v1.sa : k => v }
# }

output "service_accounts" {
  value = [
    kubernetes_service_account_v1.sa.metadata.0.name
  ]
}

output "role_bindings" {
  value = [
    kubernetes_cluster_role_binding.ccm-visibility-clusterrolebinding.metadata.0.name,
    kubernetes_cluster_role_binding.harness-autostopping-sa.metadata.0.name,
    kubernetes_cluster_role_binding.harness-autostopping-secret-reader-sa.metadata.0.name
  ]
}

output "deployments" {
  value = [
    try(kubernetes_deployment_v1.autostopping-router.metadata.0.name, "NONE"),
    try(kubernetes_deployment_v1.autostopping-controller.metadata.0.name, "NONE")
  ]
}
output "services" {
  value = [
    try(kubernetes_service_v1.autostopping-router.metadata.0.name, "NONE"),
    try(kubernetes_service_v1.autostopping-controller.metadata.0.name, "NONE")
  ]
}
output "namespace" {
  value = [
    kubernetes_namespace_v1.autostopping.metadata.0.name
  ]
}
output "cluster_roles" {
  value = [
    kubernetes_cluster_role_v1.ccm-visibility-clusterrole.metadata.0.name,
    kubernetes_cluster_role_v1.ccm-autostopping-clusterrole.metadata.0.name,
    kubernetes_cluster_role_v1.autostopping-secret-reader-role.metadata.0.name,
  ]
}

output "configmaps" {
  value = [
    kubernetes_config_map_v1.as-router-config.metadata.0.name,
    kubernetes_config_map_v1.harness-autostopping-enforcement.metadata.0.name
  ]
}

output "metrics_server_service_metadata" {
  value = try(data.kubernetes_service_v1.metrics_server.metadata, {})
}



