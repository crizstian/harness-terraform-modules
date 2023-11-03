locals {

  service_definition = { for svc, value in var.harness_platform_services : svc => merge(
    var.harness_platform_service_configs[value.SERVICE_DEFINITION.type],
    value.SERVICE_DEFINITION
    )
  }

  service_connectors = { for svc, details in local.service_definition : svc => merge(
    flatten([
      for type, connectors in var.connectors : [
        for tipo, connector in try(details.CONNECTORS, {}) : {
          for key, value in connector : key => {
            id = connectors[value].identifier
          }
        } if "${tipo}_connectors" == type
      ]
    ])...
  ) if details.enable }

  service_org_id = merge([for service, values in var.harness_platform_services : { for org, details in var.organizations : service => details.identifier if lower(org) == lower(try(values.SERVICE_DEFINITION.organization, "")) }]...)
  service_prj_id = merge([for service, values in var.harness_platform_services : { for prj, details in var.projects : service => details.identifier if lower(prj) == lower(try(values.SERVICE_DEFINITION.project, "")) }]...)
  service_tpl_dp_id = {
    for svc, values in var.harness_platform_services : svc => {
      template-deployment = {
        template_id      = try(var.templates.template_deployments[local.service_definition[svc].template.template-deployment.template_name].identifier, "")
        template_version = try(local.service_definition[svc].template.template-deployment.template_version, "")
      }
    }
  }

  svc_artifacts_gcr = { for svc, value in var.harness_platform_services : svc => [
    for k, v in try(local.service_definition[svc].artifacts.gcr, {}) : <<-EOT
    identifier: ${upper(k)}
      type: Gcr
      spec:
        connectorRef: ${try(var.connectors.default_connectors.gcr_connector_id, try(local.service_definition[svc].CONNECTORS.gcr_connector_id, ""))}
        registryHostname: ${try(local.service_definition[svc].registry, "NOT_DEFINED")}
        imagePath: ${v}
        tag: <+input>
    EOT
    ]
  }
  svc_manifest_helm_chart = { for svc, value in var.harness_platform_services : svc => [
    for k, v in try(local.service_definition[svc].MANIFESTS, {}) : <<-EOT
    manifest:
      identifier: ${k}
      type: ${v.type}
      spec:
        store:
          spec:
            connectorRef: ${try(var.connectors["helm_connectors"][local.service_definition[svc].CONNECTORS.helm_connector_id].identifier, try(local.service_definition[svc].CONNECTORS.helm_connector_id, var.connectors.default_connectors.helm_connector_id, ""))}
          type: Http
        chartName: "${v.chartName}"
        chartVersion: "${v.chartVersion}"
        helmVersion: "${v.helmVersion}"
        skipResourceVersioning: false
        nableDeclarativeRollback: false
        fetchHelmChartMetadata: false
        %{if can(v.commandFlags)}
        commandFlags:                
          - commandType: Upgrade                  
            flag: |-                    
              ${v.commandFlags["Upgrade"].flag}
        %{endif}
    EOT
    if v.type == "HelmChart"
    ]
  }
  svc_manifest_k8s = { for svc, value in var.harness_platform_services : svc => [
    for k, v in try(local.service_definition[svc].MANIFESTS, {}) : <<-EOT
    manifest:
      identifier: ${k}
      type: ${v.type}
      spec:
        store:
          spec:
            connectorRef: ${try(var.connectors.default_connectors.git_connector_id, try(local.service_definition[svc].CONNECTORS.git_connector_id, ""))}
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
    for k, v in try(local.service_definition[svc].MANIFESTS, {}) : <<-EOT
    manifest:
      identifier: ${k}
      type: ${v.type}
      spec:
        store:
          spec:
            %{if v.git_provider != "Harness"}
            connectorRef: ${try(var.connectors.default_connectors.git_connector_id, try(local.service_definition[svc].CONNECTORS.git_connector_id, ""))}
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

  service_manifests = { for svc, details in var.harness_platform_services : svc => flatten(concat(try(local.svc_manifest_helm_chart[svc], []), try(local.svc_manifest_k8s[svc], []), try(local.svc_manifest_values[svc], []))) }

  services = { for svc, details in var.harness_platform_services : svc => {
    vars = merge(
      try(var.connectors.default_connectors, {}),
      try(local.service_definition[svc].CONNECTORS, {}),
      try(local.service_tpl_dp_id[svc], {}),
      local.service_definition[svc],
      local.service_connectors[svc],
      {
        svc           = "${svc}"
        identifier    = "${lower(replace(svc, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags          = concat(try(local.service_definition[svc].tags, []), var.tags)
        org_id        = try(local.service_org_id[svc], "") != "" ? local.service_org_id[svc] : try(details.org_id, var.common_values.org_id)
        project_id    = try(local.service_prj_id[svc], "") != "" ? local.service_prj_id[svc] : try(details.project_id, var.common_values.project_id)
        manifests     = local.service_manifests[svc]
        gcr_artifacts = flatten(concat(try(local.svc_artifacts_gcr[svc], [])))
      }
  ) } if local.service_definition[svc].enable }
}
