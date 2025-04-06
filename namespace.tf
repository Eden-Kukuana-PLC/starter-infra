resource "kubernetes_namespace" "namespaces" {
  for_each = toset(local.namepaces)

  metadata {
    annotations = {
      name = each.value
    }

    labels = {
      environment = each.value
    }

    name = each.value
  }

}