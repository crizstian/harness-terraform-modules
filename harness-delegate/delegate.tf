resource "null_resource" "sanity_delegate_check" {
  for_each = local.delegates

  triggers = {
    delegates = "${each.key}"
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.root
    command     = <<-EOT
      request=$(curl -s -X GET '${local.harness_filestore_api}/${each.value.identifier}?${each.value.url_args}' -H 'x-api-key: ${var.harness_platform_api_key}')
      response=$(echo $request | jq .code)

      if [[ $response != *ENTITY_NOT_FOUND* ]]; then
        # pull delegate file
        curl -s -X GET \
            '${local.harness_filestore_api}/files/${each.value.identifier}/download?${each.value.url_args}' \
             -H 'x-api-key: ${var.harness_platform_api_key}' > ${each.value.manifest}
      else
        # generate delegate file
        curl -s -o ${each.value.manifest} \
          --location \
          --request POST '${each.value.delegate_endpoint}?${each.value.url_args}' \
          --header 'Content-Type: application/json' \
          --header 'x-api-key: ${var.harness_platform_api_key}' --data-raw '${each.value.body}'
      fi
      EOT
  }
}

resource "null_resource" "harness_folder" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.root
    command     = <<-EOT
      request=$(curl -s -X GET '${local.harness_filestore_api}/${local.harness_organization_id}?${local.account_args}' -H 'x-api-key: ${var.harness_platform_api_key}')
      response=$(echo $request | jq '.code')

      if [[ $response == *ENTITY_NOT_FOUND* ]]; then
        # create folder
        curl -i -s -X POST \
        '${local.harness_filestore_api}?${local.account_args}' \
        -H 'Content-Type: multipart/form-data' \
        -H 'x-api-key: ${var.harness_platform_api_key}' \
        -F identifier="${local.harness_organization_id}" \
        -F name="${local.harness_organization_id}" \
        -F type="FOLDER" \
        -F parentIdentifier="Root" \
        -F description="FileStore folder generated by terraform"
      fi
      EOT
  }
}

resource "null_resource" "harness_file" {
  depends_on = [
    null_resource.harness_folder
  ]

  for_each = local.delegates

  triggers = {
    delegates = "${each.key}"
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.root
    command     = <<-EOT
      request=$(curl -s -X GET '${local.harness_filestore_api}/${each.value.identifier}?${local.account_args}' -H 'x-api-key: ${var.harness_platform_api_key}')
      response=$(echo $request | jq '.code')

      if [[ $response == *ENTITY_NOT_FOUND* ]]; then
      curl -i -s -X POST \
        '${local.harness_filestore_api}?${local.account_args}' \
        -H 'Content-Type: multipart/form-data' \
        -H 'x-api-key: ${var.harness_platform_api_key}' \
        -F identifier="${each.value.identifier}" \
        -F name="${each.key}" \
        -F type="FILE" \
        -F parentIdentifier="${local.harness_organization_id}" \
        -F description="FileStore file generated by terraform" \
        -F fileUsage="SCRIPT" \
        -F tags="[]" \
        -F mimeType="txt" \
        -F content=''

      curl -i -s -X PUT \
        '${local.harness_filestore_api}/${each.value.identifier}?${local.account_args}' \
        -H 'Content-Type: multipart/form-data' \
        -H 'x-api-key: ${var.harness_platform_api_key}' \
        -F identifier="${each.value.identifier}" \
        -F name="${each.key}" \
        -F type="FILE" \
        -F parentIdentifier="${local.harness_organization_id}" \
        -F description="FileStore file generated by terraform" \
        -F fileUsage="SCRIPT" \
        -F tags="[]" \
        -F mimeType="txt" \
        -F content="$(cat ${each.value.manifest})"
      fi
      EOT
  }
}
