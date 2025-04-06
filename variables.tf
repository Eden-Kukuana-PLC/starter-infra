variable "k8s_version" {
  description = "The Kubernetes version to use for this cluster. (required)"
  default     = "1.31"
}


variable "ghcr_username" {
  description = "The username to use to connect to the Kubernetes API server to ghrc"
  type        = string
}

variable "ghcr_password" {
  description = "The password to use to connect to the Kubernetes API Server to ghrc"
  type        = string
  sensitive   = true
}

variable "ghcr_email" {
  description = "The email to use for ghrc authentication"
  type        = string
}

variable "traefik_version" {
  description = "The version to use for Traefik helm chart"
  type        = string
  default     = "33.0.0"
}

variable "kubevela_core_version" {
  description = "The version to use for Kubevela core helm chart"
  type        = string
    default     = "1.10.0-alpha.1"
}

variable "kube_config_path" {
  description = "The absolute path to the kube config file."
  type = string
}

variable "grafana_helm_chart_version" {
  description = "The version to use for Grafana helm chart"
  type        = string
  default     = "8.9.0"
}

variable "loki_helm_chart_version" {
  description = "The version to use for Loki helm chart"
  type        = string
  default     = "6.25.1"
}

variable "alloy_helm_chart_version" {
  description = "The version to use for Alloy helm chart"
  type        = string
  default     = "0.11.0"
}

variable "s3_bucket_tempo" {
  description = "S3 bucket for storing Tempo traces"
  type        = string
}

variable "s3_bucket_mimir" {
  description = "S3 bucket for storing Mimir blocks"
  type        = string
}

variable "s3_bucket_ruler_storage" {
  description = "S3 bucket for Mimir ruler storage"
  type        = string
}


variable "s3_access_key_monitoring" {
  description = "S3 access key for authentication into all monitoring buckets"
  type        = string
  sensitive   = true
}

variable "s3_secret_key_monitoring" {
  description = "S3 secret key for authentication into all monitoring buckets"
  type        = string
  sensitive   = true
}

variable "s3_endpoint" {
  description = "S3 endpoint URL"
  type        = string
}

variable "s3_bucket_loki" {
  description = "S3 bucket for storing Loki data (chunks, index, ruler)"
  type        = string
}

variable "s3_bucket_alertmanager_storage" {
  description = "S3 bucket for storing alert manager data"
  type        = string
}

