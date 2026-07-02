output "node_group_name" {
  description = "Name prefix of the created GPU EKS managed node group."
  value       = local.node_group_name
}

output "node_group_id" {
  description = "ID of the created GPU EKS managed node group."
  value       = module.gpu_node_group.nodegroup_id
}

output "node_role_arn" {
  description = "ARN of the IAM role used by the GPU node pool and added to aws-auth."
  value       = local.node_role_arn
}

output "gpu_ami_id" {
  description = "The AMI ID the GPU nodes are launched from."
  value       = data.aws_ami.gpu_ami.image_id
}

output "driver_version" {
  description = "The NVIDIA driver version installed on the new node pool."
  value       = var.driver_version
}
