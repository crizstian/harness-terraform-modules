resource "kubernetes_manifest" "autostoppping-crd" {
  manifest = yamldecode(file("${path.module}/manifiestos/autostoppping-crd.yml"))
}

data "kubernetes_service_v1" "metrics_server" {
  metadata {
    name      = "metrics-server"
    namespace = "kube-system"
  }
}
