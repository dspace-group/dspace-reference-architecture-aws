# ---------------------------------------------------------------------------
# Look up the existing cluster and account context
# ---------------------------------------------------------------------------
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

# Same GPU AMI lookup the main configuration uses (Ubuntu EKS optimized image).
data "aws_ami" "gpu_ami" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["*ubuntu-eks/k8s_${local.kubernetes_version}/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server*"]
  }
}

# Existing aws-auth ConfigMap so we can merge (not overwrite) the new node role.
data "kubernetes_config_map_v1" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
}

locals {
  kubernetes_version     = coalesce(var.kubernetes_version, data.aws_eks_cluster.cluster.version)
  driver_version_escaped = replace(var.driver_version, ".", "-")
  node_group_name        = "gpuexecnodes-${local.driver_version_escaped}"
  subnet_ids             = length(var.subnet_ids) > 0 ? var.subnet_ids : data.aws_eks_cluster.cluster.vpc_config[0].subnet_ids

  # The node-group module names the IAM role deterministically as
  # "<cluster id>-<node group name>", so the ARN can be derived up front and
  # used for the aws-auth entry without creating a dependency cycle.
  node_role_arn = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${data.aws_eks_cluster.cluster.id}-${local.node_group_name}"

  existing_map_roles = try(yamldecode(data.kubernetes_config_map_v1.aws_auth.data["mapRoles"]), [])

  # Drop any pre-existing entry for this exact role so re-applies stay idempotent.
  map_roles_without_new = [
    for role in local.existing_map_roles : role
    if try(role.rolearn, "") != local.node_role_arn
  ]

  merged_map_roles = concat(local.map_roles_without_new, [
    {
      rolearn  = local.node_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    }
  ])
}

# ---------------------------------------------------------------------------
# Allow the new node role to join the cluster (CONFIG_MAP auth mode)
# ---------------------------------------------------------------------------
resource "kubernetes_config_map_v1_data" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode(local.merged_map_roles)
  }

  # Take ownership of the mapRoles field of the already existing ConfigMap.
  force = true
}

# ---------------------------------------------------------------------------
# The additional GPU node pool (reuses the existing node-group module)
# ---------------------------------------------------------------------------
module "gpu_node_group" {
  source = "../modules/eks/modules/node-group"

  node_group_name           = local.node_group_name
  subnet_ids                = local.subnet_ids
  worker_security_group_ids = [data.aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id]
  instance_types            = var.gpu_node_size
  capacity_type             = "ON_DEMAND"
  max_size                  = var.gpu_node_count_max
  min_size                  = var.gpu_node_count_min
  custom_ami_id             = data.aws_ami.gpu_ami.image_id
  ami_type                  = "BOTTLEROCKET_x86_64" # ignored when custom_ami_id is set
  block_device_name         = "/dev/sda1"
  volume_size               = var.gpu_node_disk_size

  k8s_labels = {
    "purpose"    = "gpu"
    "gpu-driver" = var.driver_version
  }

  k8s_taints = [
    {
      key    = "purpose"
      value  = "gpu"
      effect = "NO_SCHEDULE"
    }
  ]

  node_group_context = {
    eks_cluster_id    = data.aws_eks_cluster.cluster.id
    cluster_ca_base64 = data.aws_eks_cluster.cluster.certificate_authority[0].data
    cluster_endpoint  = data.aws_eks_cluster.cluster.endpoint
    cluster_version   = local.kubernetes_version
    aws_context = {
      partition_dns_suffix = data.aws_partition.current.dns_suffix
      partition_id         = data.aws_partition.current.partition
    }
  }

  tags = local.tags

  # Make sure the role is allowed to join before the nodes come up.
  depends_on = [kubernetes_config_map_v1_data.aws_auth]
}

# ---------------------------------------------------------------------------
# Install the new driver version on the new node pool via the GPU operator
# (the operator and its NVIDIADriver CRD are assumed to be already installed)
# ---------------------------------------------------------------------------
resource "kubectl_manifest" "nvidia_driver" {
  yaml_body = <<YAML
apiVersion: nvidia.com/v1alpha1
kind: NVIDIADriver
metadata:
  name: driver-gpu-nodes-${local.driver_version_escaped}
spec:
  driverType: gpu
  image: driver
  repository: nvcr.io/nvidia
  nodeSelector:
    gpu-driver: ${var.driver_version}
  tolerations:
  - key: purpose
    operator: Equal
    value: gpu
    effect: NoSchedule
  - key: nvidia.com/gpu
    value: ""
    operator: Exists
    effect: NoSchedule
  version: ${var.driver_version}
YAML

  depends_on = [module.gpu_node_group]
}
