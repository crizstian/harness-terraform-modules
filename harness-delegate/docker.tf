resource "null_resource" "download_docker_delegate_manifest" {
  for_each = merge(local.local_docker_delegates, local.remote_docker_delegates)

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.root
    command     = <<-EOT
        curl -o ../contrib/manifests/${each.value.docker_manifest} \
        --location \
        --request POST '${local.harness_download_docker_delegate_endpoint}?orgIdentifier=${each.value.org_id}' \
        --header 'Content-Type: application/json' \
        --header 'x-api-key: ${var.harness_platform_api_key}' --data-raw '${each.value.body}'
        EOT
  }
}

# resource "null_resource" "deploy_docker_delegate" {
#     for_each   = local.local_docker_delegates
#     depends_on = [null_resource.download_docker_delegate_manifest]

#     provisioner "local-exec" {
#         working_dir = path.root
#         command     = "docker-compose -f ../contrib/manifests/${each.value.docker_manifest} up -d"
#     }
# }

# resource "null_resource" "modify_anka_docker_delegate" {
#     for_each   = local.anka_remote_docker_delegates
#     depends_on = [null_resource.download_docker_delegate_manifest]

#     provisioner "local-exec" {
#         working_dir = path.root
#         interpreter = ["/bin/bash" ,"-c"]
#         command     = <<-EOT
#             yq -i '.services.harness-ng-delegate.environment[17] = "RUNNER_URL=http://host.docker.internal:3000/"' ../contrib/manifests/${each.value.docker_manifest}
#             yq -i '.services.harness-ng-delegate.extra_hosts[0] = "host.docker.internal:host-gateway"' ../contrib/manifests/${each.value.docker_manifest}
#         EOT
#     }
# }

# resource "null_resource" "remote_deploy_docker_delegate" {
#     for_each   = local.remote_docker_delegates
#     depends_on = [null_resource.download_docker_delegate_manifest]

#     connection {
#         type        = "ssh"
#         user        = each.value.remote.user
#         host        = each.value.remote.host
#         private_key = file("../contrib/cert/${each.value.remote.private_key}")
#     }

#     provisioner "file" {
#         source      = "../contrib/manifests/${each.value.docker_manifest}"
#         destination = "/tmp/${each.value.docker_manifest}"
#     }

#     provisioner "remote-exec" {
#         inline = [
#             "export PATH=$PATH:/usr/local/bin/",
#             "docker-compose -f /tmp/${each.value.docker_manifest} up -d"
#         ]
#     }
# }
