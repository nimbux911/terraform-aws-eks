output "security_group_worker_arn" {
  value = aws_security_group.eks_worker.id
}

output "worker_role_arn" {
  value = aws_iam_role.eks_worker.arn
}

output "worker_role_id" {
  value = aws_iam_role.eks_worker.id
}

output "eks_certificate_authority" {
  value = aws_eks_cluster.main.certificate_authority.0.data
}

output "eks_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "eks_cluster_name" {
  value = aws_eks_cluster.main.id
}

output "eks_managed_node_groups_autoscaling_group_names" {
  description = "List of the autoscaling group names created by EKS managed node groups"
  value       = compact(flatten([for group in aws_eks_node_group.eks : group.resources[*].autoscaling_groups[*].name]))
}

output "oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  value       = try(replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", ""), null)
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`"
  value       = try(aws_iam_openid_connect_provider.oidc_provider[0].arn, null)
}

output "cluster_tls_certificate_sha1_fingerprint" {
  description = "The SHA1 fingerprint of the public key of the cluster's certificate"
  value       = try(data.tls_certificate.cert[0].certificates[0].sha1_fingerprint, null)
}

output "ebs_csi_iam_role_arn" {
  description = "The arn of the role created for ebs csi driver"
  value       = try(module.ebs_csi_controller_role.iam_role_arn, null)
}