resource "local_file" "template" {
  for_each = var.harness_templates
  triggers = {
    template = each.key
  }
  content  = templatefile(each.value.file, merge(each.value.vars, { name = each.key }))
  filename = "${path.module}/${each.key}.yml"
}

data "local_file" "template" {
  depends_on = [
    local_file.template,
  ]
  for_each = var.harness_templates
  triggers = {
    template = each.key
  }
  filename = "${path.module}/${each.key}.yml"
}

output "files" {
  value = { for name, value in data.local_file.template : name => "${path.module}/${name}.yml" }
}
