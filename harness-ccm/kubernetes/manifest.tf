resource "kubernetes_manifest" "autostoppping-crd" {
  manifest = yamldecode(file("./manifiestos/autostoppping-crd.yml"))
}

data "kubernetes_service_v1" "metrics_server" {
  count = strcontains(terraform.workspace, "anthos") ? 0 : 1
  metadata {
    name      = "metrics-server"
    namespace = "kube-system"
  }
}
