locals {

  worker_role = <<EOF
- rolearn: ${aws_iam_role.eks_worker.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes

EOF

  add_configmap_roles = join("\n", 
    [ for role in var.add_configmap_roles : 
      templatefile("${path.module}/resources/configmap_aws_auth.tpl",
      {
        iam_entity = "role"
        arn        = role.role_arn,
        k8s_user   = role.k8s_user,
        k8s_groups = role.k8s_groups
      }
    ) ]
  )

  add_configmap_users = join("\n", 
    [ for user in var.add_configmap_users : 
      templatefile("${path.module}/resources/configmap_aws_auth.tpl",
      {
        iam_entity = "user"
        arn        = user.user_arn,
        k8s_user   = user.k8s_user,
        k8s_groups = user.k8s_groups
      }
    ) ]
  )


}


resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.eks_master.arn

  enabled_cluster_log_types = var.enabled_cluster_log_types

  vpc_config {
    subnet_ids              = var.subnets_ids
    security_group_ids      = [aws_security_group.eks_master.id]
    endpoint_private_access = var.eks_api_private
    endpoint_public_access  = var.eks_api_private ? false : true
  }

  tags = merge({Name="${var.cluster_name}-master"}, var.eks_tags)
}


resource "time_sleep" "wait_20_seconds" {
  depends_on = [aws_eks_cluster.main]
  create_duration = "20s"
}



resource "kubernetes_config_map" "aws_auth" {
  count = var.aws_auth_ignore_changes ? 1 : 0

  metadata {
    name = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = var.add_configmap_roles == [] ? local.worker_role : format("${local.worker_role}%s", local.add_configmap_roles)
    mapUsers = local.add_configmap_users
  }

  lifecycle {
    ignore_changes = [data]
}
  depends_on = [time_sleep.wait_20_seconds]
  
}

resource "kubernetes_config_map" "aws_auth_without_ignore" {
  count = var.aws_auth_ignore_changes ? 0 : 1

  metadata {
    name = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = var.add_configmap_roles == [] ? local.worker_role : format("${local.worker_role}%s", local.add_configmap_roles)
    mapUsers = local.add_configmap_users
  }

  depends_on = [time_sleep.wait_20_seconds]

}

# Addons

resource "aws_eks_addon" "this" {
  for_each                 = var.eks_addons
  cluster_name             = var.cluster_name
  addon_name               = each.key
  addon_version            = each.value["version"]
  configuration_values     = try(jsonencode(each.value["configuration_values"]), null)
  service_account_role_arn = try(each.value["service_account_role_arn"], null)
  resolve_conflicts        = try(each.value["resolve_conflicts"], "OVERWRITE")
}


# IRSA

data "tls_certificate" "cert" {
  count = var.enable_irsa ? 1 : 0
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  count = var.enable_irsa ? 1 : 0

  client_id_list  = distinct(compact(concat(["sts.amazonaws.com"], var.openid_connect_audiences)))
  thumbprint_list = concat(data.tls_certificate.cert[0].certificates[*].sha1_fingerprint, var.custom_oidc_thumbprints)
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = merge(
    { Name = "${var.cluster_name}-eks-irsa" },
    var.eks_tags
  )
}