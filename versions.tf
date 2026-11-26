terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.28.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "= 3.5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "= 3.3.0"
    }
    kubectl = {
      source  = "hashicorp-oss/kubectl"
      version = "= 0.1.14"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "= 4.4.2"
    }
    http = {
      source  = "hashicorp/http"
      version = "= 3.6.3"
    }
  }
}
