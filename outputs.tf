output "security_group_worker_arn" {
  value = aws_security_group.eks_worker.id
}

output "worker_role_arn" {
  value = aws_iam_role.eks_worker.arn
}

output "worker_role_id" {
  value = aws_iam_role.eks_worker.id
}

output "asg_name" {
  value = aws_autoscaling_group.eks.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_cert" {
  value = base64decode(aws_eks_cluster.main.certificate_authority.0.data)
}