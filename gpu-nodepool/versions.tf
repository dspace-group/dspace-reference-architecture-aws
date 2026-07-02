terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.60.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.19.0"
    }
  }

  # This is a standalone configuration with its own state. It only manages the
  # additional GPU node pool and its NVIDIADriver custom resource, never the
  # rest of the cluster. Configure a dedicated backend so it does not collide
  # with the main infrastructure state, e.g.:
  #
  # backend "s3" {
  #   bucket = "my-tfstate-bucket"
  #   key    = "gpu-nodepool/terraform.tfstate"
  #   region = "eu-central-1"
  # }
}
