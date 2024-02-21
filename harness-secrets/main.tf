resource "harness_platform_secret_text" "secret" {
  for_each                  = local.secrets_text
  identifier                = each.value.identifier
  name                      = each.key
  description               = each.value.description
  secret_manager_identifier = each.value.secret_manager_identifier
  value_type                = each.value.value_type
  value                     = each.value.value
}

resource "harness_platform_secret_file" "secret" {
  for_each                  = local.secrets_file
  identifier                = each.value.identifier
  name                      = each.key
  description               = each.value.description
  secret_manager_identifier = each.value.secret_manager_identifier
  file_path                 = each.value
}
