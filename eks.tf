locals {

  worker_role = <<EOF
- rolearn: ${aws_iam_role.eks_worker.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
EOF
}


resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.eks_master.arn

  vpc_config {
    subnet_ids              = var.subnets_ids
    security_group_ids      = [aws_security_group.eks_master.id]
    endpoint_private_access = var.eks_api_private
    endpoint_public_access  = var.eks_api_private ? false : true
  }

  tags = merge({Name="${var.cluster_name}-master"}, var.eks_tags)
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = var.add_configmap_roles == "" ? local.worker_role : format("${local.worker_role}%s", var.add_configmap_roles)
  }

  lifecycle {
    ignore_changes = [data]
}

  depends_on = [aws_eks_cluster.main]
}