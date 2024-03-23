resource "harness_platform_gitops_agent" "agent" {
  for_each = local.gitops_agents
  identifier = each.value.identifier
  account_id = each.value.account_id
  org_id     = each.value.org_id
  project_id = each.value.project_id
  name       = each.key
  type       = each.value.type
  metadata {
    namespace         = each.value.namespace
    high_availability = each.value.high_availability
  }
}

resource "harness_platform_gitops_cluster" "cluster" {
  for_each = local.gitops_cluster
  identifier = each.value.identifier
  account_id = each.value.account_id
  org_id     = each.value.org_id
  project_id = each.value.project_id
  agent_id   = each.value.agent_id

  request {
    upsert = each.value.upsert
    cluster {
      server = each.value.server
      name   = each.key
      config {
        tls_client_config {
          insecure = each.value.insecure
        }
        cluster_connection_type = each.value.cluster_connection_type
      }
    }
  }
  lifecycle {
    ignore_changes = [
      request.0.upsert, request.0.cluster.0.config.0.bearer_token,
    ]
  }
}

resource "harness_platform_gitops_applications" "app" {
  for_each = local.gitops_applications
  identifier = each.value.identifier
  account_id = each.value.account_id
  org_id     = each.value.org_id
  project_id = each.value.project_id
  cluster_id = each.value.cluster_id
  agent_id   = each.value.agent_id
  repo_id    = each.value.repo_id
  name       = each.key

  application {
    metadata {
      annotations = each.value.metadata.annotations
      labels      = each.value.metadata.labels
      name        = each.key
    }
    spec {
      sync_policy {
        sync_options = each.value.application.spec.sync_policy.sync_options
      }
      source {
        target_revision = each.value.application.spec.source.target_revision
        repo_url        = each.value.application.spec.source.repo_url
        path            = each.value.application.spec.source.path
      }
      destination {
        namespace = each.value.application.spec.destination.namespace
        server    = each.value.application.spec.destination.server
      }
    }
  }
}
