
resource "null_resource" "add_kubevela_experimental_addon_registry" {
  depends_on = [helm_release.kubevela]
  triggers = {
    cluster_id = helm_release.kubevela.id
  }
  provisioner "local-exec" {
    command = <<EOT
      export KUBECONFIG=${var.kube_config_path}
      vela addon registry add experimental --type=helm --endpoint=https://addons.kubevela.net/experimental/ --insecureSkipTLS;
      exit;
    EOT
  }
}

# Required for deploying helm charts using kubevela
resource "null_resource" "enable_fluxcd" {
  triggers = {
    kubevela = helm_release.kubevela.id
  }
  provisioner "local-exec" {
    command = <<EOT
      export KUBECONFIG=${var.kube_config_path}
      vela addon enable fluxcd
      exit 0;
    EOT
  }
}

resource "null_resource" "initialise_kubevela_environments" {
  depends_on = [null_resource.add_kubevela_experimental_addon_registry]
  triggers = {
    cluster_id = helm_release.kubevela.id
  }
  provisioner "local-exec" {
    command = <<EOT
      export KUBECONFIG=${var.kube_config_path}
      vela env init production --namespace production
      vela env init playground --namespace playground
      exit 0;
    EOT
  }
}

resource "null_resource" "apply_traefik_ingress_route_trait" {
  depends_on = [null_resource.initialise_kubevela_environments]
  triggers = {
    cluster_id = helm_release.kubevela.id
  }
  provisioner "local-exec" {
    command = <<EOT
      export KUBECONFIG=${var.kube_config_path}
      vela def apply ${path.module}/kubevela/traits/traefik-ingress-route.cue
      exit;
    EOT
  }
}

resource "null_resource" "apply_env_from_trait" {
  depends_on = [null_resource.initialise_kubevela_environments]
  triggers = {
    cluster_id = helm_release.kubevela.id
  }
  provisioner "local-exec" {
    command = <<EOT
      export KUBECONFIG=${var.kube_config_path}
      vela def apply ${path.module}/kubevela/traits/env-from.cue
      exit;
    EOT
  }
}
