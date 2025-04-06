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