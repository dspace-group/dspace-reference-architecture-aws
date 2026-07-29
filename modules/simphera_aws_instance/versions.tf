terraform {
  required_version = ">= 1.3.0"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28.0"
      # beginning with version 5.0 some arguments are removed from resource "aws_vpc".
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 3.0.1"
    }

    http = {
      source  = "hashicorp/http"
      version = ">= 3.4.3"
    }
  }
}
