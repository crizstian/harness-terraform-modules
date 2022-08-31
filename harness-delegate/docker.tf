resource "null_resource" "download_docker_delegate_manifest" {
  for_each = merge(local.local_docker_delegates, local.remote_docker_delegates)

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.root
    command     = <<-EOT
        curl -o ${each.value.docker_manifest} \
        --location \
        --request POST '${local.harness_download_docker_delegate_endpoint}?${each.value.url_args}' \
        --header 'Content-Type: application/json' \
        --header 'x-api-key: ${var.harness_platform_api_key}' --data-raw '${each.value.body}'

        cat ${each.value.docker_manifest}
        EOT
  }
}

resource "null_resource" "modify_anka_docker_delegate" {
  for_each   = local.anka_remote_docker_delegates
  depends_on = [null_resource.download_docker_delegate_manifest]

  provisioner "local-exec" {
    working_dir = path.root
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
            yq -i '.services.harness-ng-delegate.environment[17] = "RUNNER_URL=http://host.docker.internal:3000/"' ${each.value.docker_manifest}
            yq -i '.services.harness-ng-delegate.extra_hosts[0] = "host.docker.internal:host-gateway"' ${each.value.docker_manifest}
        EOT
  }
}


data "local_file" "docker_manifests" {
  for_each   = merge(local.local_docker_delegates, local.remote_docker_delegates)
  filename   = "${path.root}/${each.value.docker_manifest}"
  depends_on = [null_resource.download_docker_delegate_manifest]
}
