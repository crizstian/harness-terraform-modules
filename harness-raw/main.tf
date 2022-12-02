resource "null_resource" "raw_request" {
  triggers = {
    always_run = "${timestamp()}"
  }

  for_each = var.harness_raw_request

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
        curl  -i -X ${each.value.request_type} '${each.value.endpoint}' \
        --header 'Content-Type: application/${each.value.content_type}' \
        --header 'x-api-key: ${var.harness_platform_api_key}' -d @${each.value.content}
        EOT
  }
}
