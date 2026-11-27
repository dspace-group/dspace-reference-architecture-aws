output "opensearch_domain_endpoint" {
  description = "Endpoint of the OpenSearch domain from the SIMPHERA instance."
  value       = try(aws_opensearch_domain.opensearch[0].endpoint, null)
}

output "buckets" {
  description = "List of S3 buckets managed by the data management module."
  value       = [for bucket in aws_s3_bucket.data_management : bucket.bucket]
}
