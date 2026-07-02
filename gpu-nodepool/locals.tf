locals {
  tags = merge(
    {
      Product = "SIMPHERA"
      Owner   = "System Team"
      Cluster = var.cluster_name
    },
    var.tags
  )
}
