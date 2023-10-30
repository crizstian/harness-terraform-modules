resource "kubernetes_config_map_v1" "as-router-config" {
  metadata {
    name      = "as-router-config"
    namespace = kubernetes_namespace_v1.autostopping.metadata.0.name
  }

  data = {
    "envoy.yaml" = <<EOT
    node:
      cluster: test-cluster
      id: test-id

    dynamic_resources:
      lds_config:
        resource_api_version: V3
        api_config_source:
          api_type: GRPC
          transport_api_version: V3
          grpc_services:
            - envoy_grpc:
                cluster_name: xds_cluster
      cds_config:
        resource_api_version: V3
        api_config_source:
          api_type: GRPC
          transport_api_version: V3
          grpc_services:
            - envoy_grpc:
                cluster_name: xds_cluster

    static_resources:
      clusters:
      - name: xds_cluster
        connect_timeout: 0.25s
        type: STRICT_DNS
        lb_policy: ROUND_ROBIN
        typed_extension_protocol_options:
          envoy.extensions.upstreams.http.v3.HttpProtocolOptions:
            "@type": type.googleapis.com/envoy.extensions.upstreams.http.v3.HttpProtocolOptions
            explicit_http_config:
              http2_protocol_options:
                connection_keepalive:
                  interval: 30s
                  timeout: 5s
        load_assignment:
          cluster_name: xds_cluster
          endpoints:
          - lb_endpoints:
            - endpoint:
                address:
                  socket_address:
                    address: autostopping-controller.harness-autostopping.svc.cluster.local
                    port_value: 18000
      - name: harness_api_endpoint
        connect_timeout: 0.25s
        type: LOGICAL_DNS
        dns_lookup_family: V4_ONLY
        lb_policy: ROUND_ROBIN
        load_assignment:
          cluster_name: harness_api_endpoint
          endpoints:
          - lb_endpoints:
            - endpoint:
                address:
                  socket_address:
                    address: app.harness.io
                    port_value: 443
        transport_socket:
          name: envoy.transport_sockets.tls
          typed_config:
            "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.UpstreamTlsContext
    EOT
  }
}

resource "kubernetes_config_map_v1" "harness-autostopping-enforcement" {
  metadata {
    name      = "harness-autostopping-enforcement"
    namespace = kubernetes_namespace_v1.autostopping.metadata.0.name
  }
  data = {
    is_active                = false
    dry_run                  = "enabled"
    excluded_namespaces      = "[]"
    notifications_enabled    = false
    notifications_usergroups = "[]"
  }
}
