resource "kubernetes_secret" "github-container-registry" {
  for_each = toset(local.namepaces)

  depends_on = [kubernetes_namespace.namespaces, null_resource.initialise_kubevela_environments]

  metadata {
    name      = "ghcr-container-registry"
    namespace = kubernetes_namespace.namespaces[each.key].metadata[0].name
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "ghcr.io" = {
          "username" = var.ghcr_username
          "password" = var.ghcr_password
          "email"    = var.ghcr_email
          "auth"     = base64encode("${var.ghcr_username}:${var.ghcr_password}")
        }
      }
    })
  }
}
