
output "cluster_eks" {
  description = "EKS cluster."
  value       = local.eks_cluster
}

output "eks_cluster_endpoint" {
  value = local.eks_cluster.endpoint
}

output "eks_cluster_certificate_authority" {
  value = local.eks_cluster.certificate_authority
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = var.cluster_name
}
