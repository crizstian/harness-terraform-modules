output "pipelines" {
  value = { for key, details in harness_platform_pipeline.pipeline : key => {
    identifier = details.identifier
    org_id     = details.org_id
    project_id = details.project_id
  } }
}
output "inputset" {
  value = { for key, details in harness_platform_input_set.inputset : key => {
    identifier = details.identifier
    org_id     = details.org_id
    project_id = details.project_id
  } }
}
output "trigger" {
  value = { for key, details in harness_platform_triggers.trigger : key => {
    identifier = details.identifier
    org_id     = details.org_id
    project_id = details.project_id
  } }
}


/* output "templates" {
  value = { for key, details in local.triggers : key => details }
} */
/* output "templates" {
  value = { for key, details in local.pipelines : key => {
    #stages    = try(keys(yamldecode(details.template_yaml).template.spec.stages), {})
    #variables = try(yamldecode(details.template_yaml).template.spec.variables, {})
    decode = merge(yamldecode(templatefile(details.vars.yaml, details.vars)), {
      template
    })
    }
  }
} */
