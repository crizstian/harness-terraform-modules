resource "kubernetes_cluster_role_v1" "ccm-visibility-clusterrole" {
  metadata {
    name = "ccm-visibility-clusterrole"
  }
  rule {
    api_groups = [""]
    resources = [
      "pods",
      "nodes",
      "nodes/proxy",
      "events",
      "namespaces",
      "persistentvolumes",
      "persistentvolumeclaims"
    ]
    verbs = [
      "get",
      "list",
      "watch"
    ]
  }
  rule {
    api_groups = [
      "apps",
      "extensions"
    ]
    resources = [
      "statefulsets",
      "deployments",
      "daemonsets",
      "replicasets"
    ]
    verbs = [
      "get",
      "list",
      "watch"
    ]
  }
  rule {
    api_groups = [
      "batch"
    ]
    resources = [
      "jobs",
      "cronjobs"
    ]
    verbs = [
      "get",
      "list",
      "watch"
    ]
  }
  rule {
    api_groups = [
      "metrics.k8s.io"
    ]
    resources = [
      "pods",
      "nodes"
    ]
    verbs = [
      "get",
      "list"
    ]
  }
  rule {
    api_groups = [
      "storage.k8s.io"
    ]
    resources = [
      "storageclasses"
    ]
    verbs = [
      "get",
      "list",
      "watch"
    ]
  }
}
resource "kubernetes_cluster_role_v1" "ccm-autostopping-clusterrole" {
  metadata {
    name = "ccm-autostopping-clusterrole"
  }
  rule {
    api_groups = ["ccm.harness.io"]
    resources = [
      "autostoppingrules",
      "autostoppingrules/status"
    ]
    verbs = [
      "get",
      "list",
      "watch",
      "delete",
      "create",
      "patch",
      "update",
      "deletecollection"
    ]
  }
  rule {
    api_groups = [
      "networking.k8s.io",
      "admissionregistration.k8s.io",
      "networking.istio.io"
    ]
    resources = [
      "ingresses",
      "validatingwebhookconfigurations",
      "virtualservices"
    ]
    verbs = [
      "get",
      "list",
      "watch",
      "delete",
      "create",
      "patch",
      "update"
    ]
  }
  rule {
    api_groups = [""]
    resources = [
      "services"
    ]
    verbs = [
      "get",
      "list",
      "watch",
      "create",
      "patch",
      "update"
    ]
  }
  rule {
    api_groups = [
      "apps",
      "extensions"
    ]
    resources = [
      "deployments",
      "statefulsets",
      "replicasets",
      "deployments/scale",
      "deployments/status",
      "statefulsets/status",
      "statefulsets/scale"
    ]
    verbs = [
      "patch",
      "update",
      "get",
      "list",
      "watch"
    ]
  }
  rule {
    api_groups = [""]
    resources = [
      "events"
    ]
    verbs = [
      "create",
      "patch"
    ]
  }
}
resource "kubernetes_cluster_role_v1" "autostopping-secret-reader-role" {
  metadata {
    name = "autostopping-secret-reader-role"
  }

  rule {
    api_groups = [""]
    resources = [
      "secrets",
      "configmaps"
    ]
    verbs = [
      "get",
      "list",
      "watch",
      "create",
      "patch",
      "delete",
      "update"
    ]
  }
}

