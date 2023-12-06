resource "kubernetes_secret_v1" "autostopping" {
  metadata {
    name      = "harness-api-key"
    namespace = kubernetes_namespace_v1.autostopping.metadata.0.name
  }
  data = {
    token = var.harness_autostopping_token
  }
}
