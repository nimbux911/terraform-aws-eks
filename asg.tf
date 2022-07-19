locals {

  nodes_common_labels = { 
    "eks.amazonaws.com/compute-type" = "ec2"
  }

  asg_common_tags = var.helm_cluster_autoscaler_enabled ? [
    {
      key                 = "kubernetes.io/cluster/${aws_eks_cluster.main.name}"
      value               = "owned"
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/enabled"
      value               = true
      propagate_at_launch = true
    },
    {
      key                 = "k8s.io/cluster-autoscaler/${aws_eks_cluster.main.name}"
      value               = "owned"
      propagate_at_launch = true
    }
  ] : [
    {
      key                 = "kubernetes.io/cluster/${aws_eks_cluster.main.name}"
      value               = "owned"
      propagate_at_launch = true
    }
  ]



}


resource "aws_key_pair" "eks" {
  key_name   = aws_eks_cluster.main.name
  public_key = base64decode(aws_ssm_parameter.eks_public_key.value)
  tags = var.eks_tags
}



resource "aws_launch_template" "eks_node_groups" {
  for_each                              = merge(var.custom_node_groups, var.managed_node_groups)
  name                                  = each.key
  image_id                              = each.value.ami_id
  instance_type                         = each.value.instance_type

  vpc_security_group_ids                = can(each.value.extra_sg_ids) ? flatten(aws_security_group.eks_worker.id, each.value.extra_sg_ids) : [aws_security_group.eks_worker.id]

  key_name                              = aws_key_pair.eks.key_name
  instance_initiated_shutdown_behavior  = "terminate"
  ebs_optimized                         = true

  user_data                             =  base64encode(templatefile("${path.module}/resources/eks_worker_userdata.tpl", 
      {
        cluster_endpoint    = aws_eks_cluster.main.endpoint,
        cluster_ca          = aws_eks_cluster.main.certificate_authority.0.data,
        cluster_name        = aws_eks_cluster.main.name,
        max_pods_enabled    = var.max_pods_per_node != null ? "--use-max-pods false" : "",
        max_pods_per_node   = var.max_pods_per_node != null ? "--max-pods=${var.max_pods_per_node}" : "",
#        node_labels         = [ for k, v in local.nodes_common_labels : "${k}=${v},"][0]
        node_labels         = can(each.value.k8s_labels) ? join(",", [ for k, v in merge(each.value.k8s_labels, local.nodes_common_labels) : "${k}=${v}"]) : join(",", [ for k,v in local.nodes_common_labels : "${k}=${v},"])
      }
    ))

  block_device_mappings {
    device_name             = "/dev/sda1"
    ebs {
      volume_size           = each.value.volume_size
      volume_type           = each.value.volume_type
      iops                  = can(each.value.volume_iops) ? each.value.volume_iops : null
      delete_on_termination = true

    }
  }

  iam_instance_profile {
    name = can(each.value.instance_profile) ? each.value.instance_profile : aws_iam_instance_profile.eks_worker.name
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = each.key
    }
  }

  lifecycle {
    create_before_destroy = true
  }

}



resource "aws_autoscaling_group" "eks" {
  for_each             = var.custom_node_groups
  min_size             = each.value.asg_min
  desired_capacity     = each.value.asg_min
  max_size             = each.value.asg_max
  name                 = each.key
  vpc_zone_identifier  = each.value.subnets_ids
  target_group_arns    = var.target_group_arns
  health_check_type    = var.health_check_type

  launch_template {
    id      = aws_launch_template.eks_node_groups[each.key].id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each  = toset(concat(local.asg_common_tags, each.value.asg_tags))
    content {
      key                   = tag.value.key
      value                 = tag.value.value
      propagate_at_launch   = tag.value.propagate_at_launch
    }
  }


  lifecycle {
    ignore_changes = [desired_capacity]
  }

}

resource "aws_eks_node_group" "eks" {
  for_each             = var.managed_node_groups

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = each.key
  node_role_arn   = can(each.value.instance_profile) ? each.value.instance_profile : aws_iam_instance_profile.eks_worker.name
  subnet_ids      = each.value.subnets_ids

  labels = each.value.k8s_labels

  dynamic "taint" {
    for_each  = each.value.k8s_taint
    content {
      key     = taint.value.key
      value   = taint.value.value
      effect  = taint.value.effect
    }
  }

  scaling_config {
    min_size     = each.value.asg_min
    desired_size = each.value.asg_min
    max_size     = each.value.asg_max
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

}