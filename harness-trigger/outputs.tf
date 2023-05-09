output "trigger" {
  value = { for key, details in harness_platform_triggers.trigger : key => {
    identifier = details.identifier
    org_id     = details.org_id
    project_id = details.project_id
  } }
}
