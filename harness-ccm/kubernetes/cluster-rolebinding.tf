resource "kubernetes_cluster_role_binding" "ccm-visibility-clusterrolebinding" {
  metadata {
    name = "ccm-visibility-clusterrolebinding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "ccm-visibility-clusterrole"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "harness-key"
    namespace = "kube-system"
  }
}
resource "kubernetes_cluster_role_binding" "harness-autostopping-sa" {
  metadata {
    name = "harness-autostopping-sa"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "ccm-autostopping-clusterrole"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "harness-autostopping-sa"
    namespace = "harness-autostopping"
  }
}
resource "kubernetes_cluster_role_binding" "harness-autostopping-secret-reader-sa" {
  metadata {
    name = "harness-autostopping-secret-reader-sa"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "autostopping-secret-reader-role"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "harness-autostopping-sa"
    namespace = "harness-autostopping"
  }
}
