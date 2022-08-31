resource "null_resource" "download_k8s_delegate_manifest" {
  for_each = local.k8s_delegates

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.root
    command     = <<-EOT
        curl -o ${each.value.k8s_manifest} \
        --location \
        --request POST '${local.harness_download_k8s_delegate_endpoint}?${each.value.url_args}' \
        --header 'Content-Type: application/json' \
        --header 'x-api-key: ${var.harness_platform_api_key}' --data-raw '${each.value.body}'
        EOT
  }
}

data "local_file" "k8s_manifests" {
  for_each   = local.k8s_delegates
  filename   = "${path.root}/${each.value.k8s_manifest}"
  depends_on = [null_resource.download_k8s_delegate_manifest]
}
