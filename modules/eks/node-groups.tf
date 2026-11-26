module "node_group" {
  source                    = "./modules/node-group"
  for_each                  = var.node_groups
  node_group_name           = each.value.node_group_name
  subnet_ids                = var.subnet_ids
  worker_security_group_ids = [aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id]
  instance_types            = each.value.instance_types
  capacity_type             = each.value.capacity_type
  max_size                  = each.value.max_size
  min_size                  = each.value.min_size
  ami_type                  = each.value.ami_type
  custom_ami_id             = try(each.value.custom_ami_id, null)
  block_device_name         = each.value.block_device_name
  volume_size               = each.value.volume_size
  k8s_labels                = try(each.value.k8s_labels, {})
  k8s_taints                = try(each.value.k8s_taints, [])
  node_group_context        = local.node_group_context
  tags                      = var.tags

  # On destroy, nodes must go before the CNI addon and its IRSA role; otherwise aws-node cannot delete its ENIs and they leak.
  depends_on = [
    aws_eks_access_entry.principal,
    aws_eks_addon.aws_vpc_cni,
    aws_iam_role_policy_attachment.aws_vpc_cni_policy_attachment,
  ]
}
