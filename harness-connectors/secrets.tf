# resource "harness_platform_secret_text" "harness_secrets" {
#   for_each                  = local.secrets
#   identifier                = "${lower(replace(each.key, "/[\\s-.]/", "_"))}_${var.suffix}"
#   name                      = each.key
#   description               = "${each.key} - ${each.value.description}"
#   secret_manager_identifier = "harnessSecretManager"
#   value_type                = "Inline"
#   value                     = each.value.secret
#   org_id                    = each.value.org_id
#   project_id                = each.value.project_id

#   lifecycle {
#     ignore_changes = [
#       value,
#     ]
#   }
# }
