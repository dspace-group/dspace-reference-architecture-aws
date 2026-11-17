resource "aws_eks_access_entry" "principal" {
  for_each          = { for p in var.map_principals : p.arn => p }
  cluster_name      = aws_eks_cluster.eks.name
  principal_arn     = each.value.arn
  kubernetes_groups = each.value.groups

  depends_on = [
    aws_eks_cluster.eks,
    data.http.eks_cluster_readiness
  ]
}
