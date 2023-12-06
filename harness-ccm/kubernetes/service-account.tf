resource "kubernetes_service_account_v1" "sa" {
  metadata {
    name      = "harness-autostopping-sa"
    namespace = kubernetes_namespace_v1.autostopping.metadata.0.name
  }
}
