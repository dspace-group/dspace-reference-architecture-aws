terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28.0"
      # minimum version 5.60.0 is required due to argument requirements for the aws_eks_cluster resource.
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 3.0.1"
    }

    kubectl = {
      source  = "hashicorp-oss/kubectl"
      version = ">= 0.1.13"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.17.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.8.0"
    }
  }
}
