output "roles" {
  value = { for k, v in harness_platform_roles.role : k => v.identifier }
}
output "users" {
  value = { for k, v in harness_platform_user.user : k => v.identifier }
}
output "usergroups" {
  value = { for k, v in harness_platform_usergroup.usergroup : k => v.identifier }
}
output "service_accounts" {
  value = { for k, v in harness_platform_service_account.service_account : k => v.identifier }
}
output "resource_groups" {
  value = { for k, v in harness_platform_resource_group.esource_groups : k => v.identifier }
}
