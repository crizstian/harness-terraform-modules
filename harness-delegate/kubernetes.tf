resource "null_resource" "download_k8s_delegate_manifest" {
  for_each = local.k8s_delegates

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.root
    command     = <<-EOT
        curl -o ${each.value.k8s_manifest} \
        --location \
        --request POST '${local.harness_download_k8s_delegate_endpoint}?orgIdentifier=${each.value.org_id}' \
        --header 'Content-Type: application/json' \
        --header 'x-api-key: ${var.harness_platform_api_key}' --data-raw '${each.value.body}'

        cat ${each.value.k8s_manifest}
        EOT
  }
}

# resource "null_resource" "deploy_k8s_delegate" {
#     for_each   = local.k8s_delegates
#     depends_on = [null_resource.download_k8s_delegate_manifest]

#     provisioner "local-exec" {
#         working_dir = path.root
#         command     = "kubectl ${var.kubeconfig_path} apply -f ../contrib/manifests/${each.value.k8s_manifest}"
#     }
# }
