resource "harness_platform_service" "services" {
  for_each    = local.services
  name        = each.key
  description = each.value.vars.description
  identifier  = each.value.vars.identifier
  org_id      = each.value.vars.org_id
  project_id  = each.value.vars.project_id
  tags        = each.value.vars.tags
  yaml        = templatefile(<<EOT
service:
  name: ${name}
  identifier: ${identifier}
  description: ${description}
  serviceDefinition:
    type: Kubernetes
    spec:
      %{ if length(variables) > 0 }
      variables:
        ${indent(8, yamlencode(variables))}
      %{ endif }
      %{ if length(artifacts) > 0 }
      artifacts:
        primary:
          primaryArtifactRef: <+input>
          sources:
            %{ if can(artifacts.gcr) }
            - identifier: GCP
              type: Gcr
              spec:
                connectorRef: ${gcr_connector_id}
                registryHostname: us.gcr.io
                imagePath: ${artifacts.gcr.gcr_image}
                tag: <+input>
            - identifier: GCP_TEMPLATE
              type: Gcr
              spec:
                connectorRef: ${gcr_connector_id}
                registryHostname: us.gcr.io
                imagePath: ${artifacts.gcr.gcr_template}
                tag: <+input>
            %{ endif }
            %{ if can(artifacts.nexus) }
            - name: Nexus
              identifier: Nexus
              template:
                templateRef: ${nexus_artifact_connector_id}
                versionLabel: "1"
                templateInputs:
                  type: CustomArtifact
                  spec:
                    version: <+input>
                    inputs:
                      - name: ARTIFACT_ID
                        type: String
                        value: ${artifacts.nexus.ARTIFACT_ID}
                      - name: ARTIFACT_GROUP
                        type: String
                        value: ${artifacts.nexus.ARTIFACT_GROUP}
            %{ endif }
            %{ if can(artifacts.gitlab) }
            - name: Gitlab
              identifier: Gitlab
              template:
                templateRef: ${git_artifact_connector_id}
                versionLabel: "1"
                templateInputs:
                  type: CustomArtifact
                  spec:
                    version: <+input>
                    inputs:
                      - name: GITID
                        type: String
                        value: ${artifacts.gitlab.GITID}
            %{ endif }
      %{ endif }
      %{ if length(manifests) > 0 }
      manifests:
      %{ for manifest in manifests }
        - ${indent(9, manifest)}
      %{ endfor }
      %{ endif }
EOT>>, each.value.vars)
}
