terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 3.0.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.5"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.4.3"
    }
  }
}
