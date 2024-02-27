output "roles" {
  value = { for k, v in harness_platform_roles.role : k => {identifier = v.identifier} }
}
output "users" {
  value = { for k, v in harness_platform_user.user : k => {identifier = v.identifier} }
}
output "usergroups" {
  value = { for k, v in harness_platform_usergroup.usergroup : k => {identifier = v.identifier} }
}
output "service_accounts" {
  value = { for k, v in harness_platform_service_account.service_account : k => {identifier = v.identifier} }
}
output "resource_groups" {
  value = { for k, v in harness_platform_resource_group.resource_group : k => {identifier = v.identifier} }
}