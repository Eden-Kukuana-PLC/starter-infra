terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.33.0" # check the latest version for compatibility
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.16.1"
    }

  }
}

provider "helm" {
  kubernetes {
    config_path = var.kube_config_path
  }
}

provider "kubernetes" {
  config_path = var.kube_config_path
}

