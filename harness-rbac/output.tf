output "users" {
  value = { for k, v in harness_platform_roles.role : k => v.identifier }
}
