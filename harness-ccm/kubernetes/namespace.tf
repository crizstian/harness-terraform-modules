resource "kubernetes_namespace_v1" "autostopping" {
  metadata {
    name = "harness-autostopping"
  }
}
