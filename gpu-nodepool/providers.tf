provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)

  # https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#exec-plugins
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--profile", var.aws_profile, "--cluster-name", data.aws_eks_cluster.cluster.name]
    command     = "aws"
  }
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--profile", var.aws_profile, "--cluster-name", data.aws_eks_cluster.cluster.name]
    command     = "aws"
  }
}
