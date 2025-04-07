resource "helm_release" "traefik" {
  name             = "traefik"
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  namespace        = "traefik"
  create_namespace = true
  version          = var.traefik_version

  values = [
    yamlencode({
      ports = {
        web = {
          redirectTo = {
            port = "websecure"
          }
        }
        websecure = {
          tls = {
            enabled      = true
            certResolver = "letsEncrypt"
          }
        }
      }

      additionalArguments = [
        "--api.insecure=true",
        "--serversTransport.insecureSkipVerify=true",
        "--tcpServersTransport.tls.insecureSkipVerify=true"
      ]

      autoscaling = {
        enabled     = true
        maxReplicas = 6
      }

      # This is disabled by autoscaling
      # comment autoscaling out to use this block
      # deployment = {
      #   replicas = 3
      # }

      logs = {
        access = {
          enabled = true
        }
      }


      providers = {
        kubernetesCRD = {
          enabled = true
        }
      }

      persistence = {
        enabled      = true
        size         = "128Mi"
        name         = "success-factors"
        path         = "/traefik/tls"
      }

      securityContext = {
        runAsNonRoot = false
        runAsGroup   = 0
        runAsUser    = 0
      }

      certificatesResolvers = {
        letsEncrypt = {
          acme = {
            tlschallenge = {}
            caServer     = "https://acme-v02.api.letsencrypt.org/directory"
            email        = "emmanuel@uplanit.co.uk"
            storage      = "/traefik/tls/acme.json"
            httpChallenge = {
              entryPoint = "web"
            }
          }
        }
      }
    })
  ]
}


resource "helm_release" "kubevela" {
  name             = "vela-core"
  repository       = "https://kubevela.github.io/charts"
  chart            = "vela-core"
  namespace        = "vela-system"
  create_namespace = true
  version          = var.kubevela_core_version
}

resource "helm_release" "postgres-operator" {
  name             = "postgres-operator"
  chart            = "${path.module}/crunchy-data-postgres-operator"
  namespace        = "postgres-operator"
  create_namespace = true

  values = [yamlencode({
    replicas = 1
  })]
}

resource "helm_release" "loki" {
  name             = "loki"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki"
  namespace        = "monitoring"
  create_namespace = true
  version          = var.loki_helm_chart_version  # Specify the Loki chart version

  # Include the base Helm chart values from the existing loki.yaml file
  values = [file("${path.module}/configs/helm-values/loki.yaml")]

  # Overwrite S3-specific configurations for Loki storage
  set {
    name  = "loki.storage.bucketNames.chunks"
    value = var.s3_bucket_loki
  }

  set {
    name  = "loki.storage.bucketNames.index"
    value = var.s3_bucket_loki
  }

  set {
    name  = "loki.storage.bucketNames.ruler"
    value = var.s3_bucket_loki
  }

  set {
    name  = "loki.storage.s3.endpoint"
    value = var.s3_endpoint
  }

  set {
    name  = "loki.storage.s3.accessKeyId"
    value = var.s3_access_key_monitoring
  }

  set {
    name  = "loki.storage.s3.secretAccessKey"
    value = var.s3_secret_key_monitoring
  }

}

resource "helm_release" "grafana" {
  depends_on       = [helm_release.loki]
  name             = "grafana"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  namespace        = "monitoring"
  create_namespace = true
  version          = var.grafana_helm_chart_version

  values = [file("${path.module}/configs/helm-values/grafana.yaml")]
}

resource "helm_release" "alloy" {
  depends_on       = [helm_release.loki]
  name             = "alloy"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "alloy"
  namespace        = "monitoring"
  create_namespace = true
  version          = var.alloy_helm_chart_version  # Specify the Loki chart version (can be updated as needed)

  values = [file("${path.module}/configs/helm-values/alloy.yaml")]
}

# resource "helm_release" "mimir" {
#   name             = "mimir"
#   repository       = "https://grafana.github.io/helm-charts"
#   chart            = "mimir-distributed"
#   namespace        = "monitoring"
#   create_namespace = true
#   version          = "5.6.0"
#
#   values           = [file("${path.module}/configs/helm-values/mimir.yaml")]
#
#   set {
#     name  = "mimir.structuredConfig.common.storage.s3.bucket_name"
#     value = var.s3_bucket_mimir
#   }
#
#   set {
#     name  = "mimir.structuredConfig.common.storage.s3.access_key_id"
#     value = var.s3_access_key_monitoring
#   }
#
#   set {
#     name  = "mimir.structuredConfig.common.storage.s3.secret_access_key"
#     value = var.s3_secret_key_monitoring
#   }
#
#   set {
#     name  = "mimir.structuredConfig.common.storage.s3.endpoint"
#     value = var.s3_endpoint
#   }
#
#   # Overwrite additional bucket for Mimir's ruler storage
#   set {
#     name  = "mimir.structuredConfig.ruler_storage.s3.bucket_name"
#     value = var.s3_bucket_ruler_storage
#   }
#
#   # Overwrite additional bucket for Mimir's blocks storage
#   set {
#     name  = "mimir.structuredConfig.blocks_storage.s3.bucket_name"
#     value = var.s3_bucket_mimir
#   }
#
#   set {
#     name  = "mimir.structuredConfig.alertmanager_storage.s3.bucket_name"
#     value = var.s3_bucket_alertmanager_storage
#   }
#
# }

resource "helm_release" "tempo" {
  name             = "tempo"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "tempo"
  namespace        = "monitoring"
  create_namespace = true
  version          = "1.19.0"

  values           = [file("${path.module}/configs/helm-values/tempo.yaml")]

  set {
    name  = "storage.trace.s3.bucket"
    value = var.s3_bucket_tempo
  }

  set {
    name  = "storage.trace.s3.access_key"
    value = var.s3_access_key_monitoring
  }

  set {
    name  = "storage.trace.s3.secret_key"
    value = var.s3_secret_key_monitoring
  }

  set {
    name  = "storage.trace.s3.endpoint"
    value = var.s3_endpoint
  }

}


resource "helm_release" "metrics-server" {
  name             = "metrics-server"
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  chart            = "metrics-server"
  namespace        = "kube-system"
  create_namespace = true
  version          = "3.12.2"

  values           = [file("${path.module}/configs/helm-values/metrics-server.yaml")]
}
