variable "aws_profile" {
  type        = string
  description = "The AWS CLI named profile used to authenticate against AWS and to fetch the EKS token."
  default     = "wtc-development"
}

variable "aws_region" {
  type        = string
  description = "The AWS region the existing EKS cluster lives in."
  default     = "eu-central-1"
}

variable "cluster_name" {
  type        = string
  description = "Name (id) of the existing EKS cluster the GPU node pool should be added to. For an EKS cluster the name and the id are identical."
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version used to look up the matching GPU AMI. When null the version of the existing cluster is used."
  default     = null
}

variable "subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs the GPU nodes are placed in. When empty the subnets configured on the existing cluster are used."
  default     = []
}

variable "driver_version" {
  type        = string
  description = "The NVIDIA GPU driver version that is installed on the new node pool by the (already deployed) GPU operator."
  default     = "595.71.05"
}

variable "gpu_node_size" {
  type        = list(string)
  description = "The instance types for the GPU node pool."
  default     = ["g6.2xlarge"]
}

variable "gpu_node_count_min" {
  type        = number
  description = "The minimum number of GPU nodes."
  default     = 0
}

variable "gpu_node_count_max" {
  type        = number
  description = "The maximum number of GPU nodes."
  default     = 1
}

variable "gpu_node_disk_size" {
  type        = number
  description = "The disk size in GiB of the GPU nodes."
  default     = 100
}

variable "tags" {
  type        = map(string)
  description = "Additional tags applied to the created resources."
  default     = {}
}
