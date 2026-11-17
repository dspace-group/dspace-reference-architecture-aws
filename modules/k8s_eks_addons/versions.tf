terraform {
  required_version = ">= 1.3.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 3.0.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.17.0"
    }

    kubectl = {
      source  = "hashicorp-oss/kubectl"
      version = ">= 0.1.13"
    }

  }
}
