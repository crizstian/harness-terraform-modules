resource "kubernetes_deployment_v1" "autostopping-router" {
  depends_on = [
    kubernetes_config_map_v1.as-router-config
  ]
  metadata {
    name      = "autostopping-router"
    namespace = kubernetes_namespace_v1.autostopping.metadata.0.name
    labels = {
      app = "autostopping-router"
    }
  }

  spec {
    replicas               = 1
    revision_history_limit = 10

    selector {
      match_labels = {
        app = "autostopping-router"
      }
    }

    template {
      metadata {
        labels = {
          app = "autostopping-router"
        }
      }

      spec {
        container {
          image             = "envoyproxy/envoy:v1.18-latest"
          name              = "envoy"
          args              = ["-c", "/etc/envoy.yaml"]
          command           = ["envoy"]
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 10000
            protocol       = "TCP"
            name           = "listener"
          }
          port {
            container_port = 9901
            protocol       = "TCP"
            name           = "admin"
          }
          volume_mount {
            mount_path = "/etc/envoy.yaml"
            name       = "as-router-config"
            sub_path   = "envoy.yaml"
          }
        }
        dns_policy     = "ClusterFirst"
        restart_policy = "Always"
        volume {
          name = "as-router-config"
          config_map {
            default_mode = "0420"
            name         = "as-router-config"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "autostopping-router" {
  metadata {
    name      = "autostopping-router"
    namespace = kubernetes_namespace_v1.autostopping.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.autostopping-router.metadata.0.labels.app
    }
    type = "ClusterIP"
    port {
      port        = 80
      target_port = 10000
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_deployment_v1" "autostopping-controller" {
  metadata {
    name      = "autostopping-controller"
    namespace = kubernetes_namespace_v1.autostopping.metadata.0.name
    labels = {
      app = "autostopping-controller"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "autostopping-controller"
      }
    }

    template {
      metadata {
        labels = {
          app = "autostopping-controller"
        }
      }

      spec {
        container {
          image             = "harness/autostopping-controller:1.0.20"
          name              = "autostopping-controller"
          image_pull_policy = "IfNotPresent"
          volume_mount {
            mount_path = "/tmp/k8s-webhook-server/serving-certs"
            name       = "serving-certs"
          }
          env {
            name  = "HARNESS_API"
            value = "https://app.harness.io/gateway/lw/api"
          }
          env {
            name  = "CONNECTOR_ID"
            value = var.kubernetes_connector_id
          }
          env {
            name  = "REMOTE_ACCOUNT_ID"
            value = var.harness_account_id
          }
          port {
            container_port = 18000
            name           = "envoy-snapshot"
          }
          port {
            container_port = 8093
            name           = "progress"
            protocol       = "TCP"
          }
          port {
            container_port = 9443
            protocol       = "TCP"
            name           = "webhook"
          }
        }
        volume {
          name = "serving-certs"
          empty_dir {}
        }
        service_account_name = "harness-autostopping-sa"
      }
    }
  }
}

resource "kubernetes_service_v1" "autostopping-controller" {
  metadata {
    name      = "autostopping-controller"
    namespace = kubernetes_namespace_v1.autostopping.metadata.0.name
    labels = {
      app = "autostopping-controller"
    }
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.autostopping-controller.metadata.0.labels.app
    }
    port {
      port     = 18000
      protocol = "TCP"
      name     = "envoy-snapshot"
    }
    port {
      port        = 80
      target_port = 8093
      protocol    = "TCP"
      name        = "progress"
    }
    port {
      port        = 9443
      target_port = 9443
      protocol    = "TCP"
      name        = "webhook"
    }
  }
}
