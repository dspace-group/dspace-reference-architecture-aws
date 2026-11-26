provider "aws" {
  default_tags {
    tags = var.tags
  }
}

locals {
  eks_auth_args = ["eks", "get-token", "--cluster-name", module.eks.eks_cluster_id]
}

provider "kubernetes" {
  host                   = module.eks.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = local.eks_auth_args
  }
}

provider "helm" {
  # Avoids parallel chart downloads colliding in %TEMP% on Windows (rename: Access is denied).
  repository_cache       = "${path.root}/.helm/cache"
  repository_config_path = "${path.root}/.helm/repositories.yaml"

  kubernetes = {
    host                   = module.eks.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.eks_cluster_certificate_authority_data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = local.eks_auth_args
    }
  }
}

provider "kubectl" {
  host                   = module.eks.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.eks_cluster_certificate_authority_data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = local.eks_auth_args
  }
}

