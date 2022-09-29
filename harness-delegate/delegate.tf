resource "null_resource" "download_delegate_manifest" {
  for_each = local.delegates

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.root
    command     = <<-EOT

      request=$(curl -s '${var.harness_api_endpoint}/delegate-token-ng/delegate-groups?${each.value.url_args}&delegateTokenName=${each.value.tokenName}' -H 'x-api-key: ${var.harness_platform_api_key}')

      result=$(echo $request | jq '.resource.delegateGroupDetails[].groupName | contains("${each.key}")')

      if [[ $(echo $result) != *true* ]]; then

          curl -o ${each.value.manifest} \
          --location \
          --request POST '${each.value.delegate_endpoint}?${each.value.url_args}' \
          --header 'Content-Type: application/json' \
          --header 'x-api-key: ${var.harness_platform_api_key}' --data-raw '${each.value.body}'
      else
        echo "delegate ${each.key} already exists"
      fi
      EOT
  }
}

data "local_file" "delegate_manifests" {
  for_each   = local.delegates
  filename   = "${path.root}/${each.value.manifest}"
  depends_on = [null_resource.download_delegate_manifest]
}
