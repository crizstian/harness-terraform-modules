locals {
  service_org_id = merge([for service, values in var.harness_platform_services : { for org, details in var.organizations : service => details.identifier if lower(org) == lower(try(values.SERVICE_DEFINITION.organization, "")) }]...)
  service_prj_id = merge([for service, values in var.harness_platform_services : { for prj, details in var.projects : service => details.identifier if lower(prj) == lower(try(values.SERVICE_DEFINITION.project, "")) }]...)
  service_tpl_dp_id = {
    for service, values in var.harness_platform_services : service => {
      template-deployment = {
        template_id      = try(var.templates.template_deployments[values.SERVICE_DEFINITION.template.template-deployment.template_name].identifier, "")
        template_version = try(values.SERVICE_DEFINITION.template.template-deployment.template_version, "")
      }
    }
  }

  svc_artifacts_gcr = { for svc, value in var.harness_platform_services : svc => [
    for k, v in try(value.SERVICE_DEFINITION.artifacts.gcr, {}) : <<-EOT
    identifier: ${upper(k)}
      type: Gcr
      spec:
        connectorRef: ${try(var.connectors.default_connectors.gcr_connector_id, try(value.CONNECTORS.gcr_connector_id, ""))}
        registryHostname: us.gcr.io
        imagePath: ${v}
        tag: <+input>
    EOT
    ]
  }
  svc_manifest_helm_chart = { for svc, value in var.harness_platform_services : svc => [
    for k, v in try(value.SERVICE_DEFINITION.manifests, {}) : <<-EOT
    manifest:
      identifier: ${k}
      type: ${v.type}
      spec:
        store:
          spec:
            connectorRef: ${try(var.connectors.default_connectors.helm_connector_id, try(value.CONNECTORS.helm_connector_id, ""))}
          type: Http
        chartName: ${v.chartName}
        chartVersion: ${v.chartVersion}
        helmVersion: ${v.helmVersion}
        skipResourceVersioning: false
    EOT
    if v.type == "HelmChart"
    ]
  }
  svc_manifest_k8s = { for svc, value in var.harness_platform_services : svc => [
    for k, v in try(value.SERVICE_DEFINITION.manifests, {}) : <<-EOT
    manifest:
      identifier: ${k}
      type: ${v.type}
      spec:
        store:
          spec:
            connectorRef: ${try(var.connectors.default_connectors.git_connector_id, try(value.CONNECTORS.git_connector_id, ""))}
            %{if can(v.reponame)}
            repoName: ${v.reponame}
            %{endif}
            gitFetchType: Branch
            branch: ${v.branch}
            paths:
              - ${v.manifest_path}
          type: ${v.git_provider}
    EOT
    if v.type == "K8sManifest"
    ]
  }
  svc_manifest_values = { for svc, value in var.harness_platform_services : svc => [
    for k, v in try(value.SERVICE_DEFINITION.manifests, {}) : <<-EOT
    manifest:
      identifier: ${k}
      type: ${v.type}
      spec:
        store:
          spec:
            %{if v.git_provider != "Harness"}
            connectorRef: ${try(var.connectors.default_connectors.git_connector_id, try(value.CONNECTORS.git_connector_id, ""))}
            %{if can(v.reponame)}
            repoName: ${v.reponame}
            %{endif}
            gitFetchType: Branch
            branch: ${v.branch}
            paths:
              - ${v.manifest_path}
            %{endif}
            %{if v.git_provider == "Harness"}
            files:
              - "${v.manifest_path}"
            %{endif}
          type: ${v.git_provider}
    EOT
    if v.type == "Values"
    ]
  }



  services = { for name, details in var.harness_platform_services : name => {
    vars = merge(
      try(details.CI, {}),
      try(var.connectors.default_connectors, {}),
      try(details.CONNECTORS, {}),
      try(local.service_tpl_dp_id[name], {}),
      details.SERVICE_DEFINITION,
      {
        name          = "${name}"
        identifier    = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags          = concat(try(details.SERVICE_DEFINITION.tags, []), var.tags)
        org_id        = try(local.service_org_id[name], "") != "" ? local.service_org_id[name] : try(details.org_id, var.common_values.org_id)
        project_id    = try(local.service_prj_id[name], "") != "" ? local.service_prj_id[name] : try(details.project_id, var.common_values.project_id)
        manifests     = flatten(concat(try(local.svc_manifest_helm_chart[name], []), try(local.svc_manifest_k8s[name], []), try(local.svc_manifest_values[name], [])))
        gcr_artifacts = flatten(concat(try(local.svc_artifacts_gcr[name], [])))
      }
  ) } if details.SERVICE_DEFINITION.enable }
}
