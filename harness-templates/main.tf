resource "local_file" "template" {
  for_each = local.templates
  content  = templatefile(each.value.file, each.value.vars)
  filename = "${path.module}/${each.key}.yml"
}

data "local_file" "template" {
  depends_on = [
    local_file.template,
  ]
  for_each = local.templates
  filename = "${path.module}/${each.key}.yml"
}

resource "null_resource" "template" {
  depends_on = [
    data.local_file.template,
  ]
  triggers = {
    always_run = "${timestamp()}"
  }
  for_each = local.templates

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.root
    command     = <<-EOT
        curl  -i -X POST '${var.harness_template_endpoint}${local.harness_template_endpoint_account_args}' \
        --header 'Content-Type: application/yaml' \
        --header 'x-api-key: ${var.harness_platform_api_key}' -d '
        ${data.local_file.template[each.key].content}
        '
        EOT
  }
}

resource "null_resource" "template-update" {
  depends_on = [
    null_resource.template
  ]
  triggers = {
    always_run = "${timestamp()}"
  }
  for_each = local.templates

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.root
    command     = <<-EOT
        curl  -i -X PUT '${var.harness_template_endpoint}${each.value.update_endpoint}' \
        --header 'Content-Type: application/yaml' \
        --header 'x-api-key: ${var.harness_platform_api_key}' -d '
        ${data.local_file.template[each.key].content}
        '
        EOT
  }
}
