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

  managed_node_groups = var.managed_node_groups != null ? {for node_group in var.managed_node_groups: node_group.name => merge(node_group.values, {type = "managed", spot_nodes_enabled = false})} : null
  custom_node_groups = var.custom_node_groups != null ? {for node_group in var.custom_node_groups: node_group.name => merge(node_group.values, {type = "custom", spot_nodes_enabled = lookup(node_group.values, "spot_nodes_enabled", false)})} : null

  eks_managed_node_groups_autoscaling_group_names = compact(flatten([for group in try(aws_eks_node_group.eks, {}) : group.resources[*].autoscaling_groups[*].name]))

  config_autoscaling_attachment = var.managed_node_groups != null ? distinct(flatten([
    for each_tg in tolist(var.target_group_arns) : [
      for node_group_name in local.eks_managed_node_groups_autoscaling_group_names : {
        autoscaling_group_name = node_group_name
        lb_target_group_arn    = each_tg
      }
  ]])) : [] 
  }

resource "aws_key_pair" "eks" {
  key_name   = aws_eks_cluster.main.name
  public_key = base64decode(aws_ssm_parameter.eks_public_key.value)
  tags       = var.eks_tags
}

resource "aws_launch_template" "eks_node_groups" {
  for_each                              = merge(local.custom_node_groups, local.managed_node_groups)
  name                                  = each.key
  image_id                              = each.value.ami_id
  instance_type                         = each.value.instance_type

  network_interfaces { 
    associate_public_ip_address = each.value.workers_public 
    delete_on_termination       = true 
    security_groups             = each.value.extra_sg_ids != null ? concat([aws_security_group.eks_worker.id], each.value.extra_sg_ids) : [aws_security_group.eks_worker.id] 
  }

  key_name                              = aws_key_pair.eks.key_name
  instance_initiated_shutdown_behavior  = each.value.type == "custom" ? "terminate" : null 
  ebs_optimized                         = true
  user_data                             =  base64encode(templatefile("${path.module}/resources/eks_worker_userdata.tpl", 
      {
        cluster_endpoint    = aws_eks_cluster.main.endpoint,
        cluster_ca          = aws_eks_cluster.main.certificate_authority.0.data,
        cluster_name        = aws_eks_cluster.main.name,
        max_pods_enabled    = var.max_pods_per_node != null ? "--use-max-pods false" : "",
        max_pods_per_node   = var.max_pods_per_node != null ? "--max-pods=${var.max_pods_per_node}" : "",
        node_labels         = each.value.k8s_labels != null ? join(",", [ for k, v in merge(each.value.k8s_labels, local.nodes_common_labels) : "${k}=${v}"]) : join(",", [ for k,v in local.nodes_common_labels : "${k}=${v},"])
      }
    ))

  block_device_mappings {
    device_name             = data.aws_ami.this[each.key].root_device_name
    ebs {
      volume_size           = each.value.volume_size
      volume_type           = each.value.volume_type
      iops                  = each.value.volume_iops != null ? each.value.volume_iops : null
      delete_on_termination = true

    }
  }

  dynamic "iam_instance_profile" {
    for_each = each.value.type == "custom" ? ["do it"] : []
    content {
      name = each.value.instance_profile != null ? each.value.instance_profile : aws_iam_instance_profile.eks_worker.name
    }
  }

  monitoring {
    enabled = var.monitoring
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
  for_each             = local.custom_node_groups != null ? local.custom_node_groups : {}
  min_size             = each.value.asg_min
  desired_capacity     = each.value.asg_min
  max_size             = each.value.asg_max
  name                 = each.key
  vpc_zone_identifier  = each.value.subnets_ids
  target_group_arns    = var.target_group_arns
  health_check_type    = var.health_check_type

  mixed_instances_policy {
    dynamic "instances_distribution" {
      for_each =  each.value.spot_nodes_enabled == true ? ["do it"] : []
      content {
        spot_allocation_strategy = var.spot_allocation_strategy
        on_demand_percentage_above_base_capacity = var.on_demand_percentage_above_base_capacity
        spot_instance_pools = var.spot_instance_pools
      }
      }

    launch_template {
      launch_template_specification {
        launch_template_id      = aws_launch_template.eks_node_groups[each.key].id
        version = "$Latest"
      }
  }
  }

  dynamic "tag" {
    for_each  = toset(concat(local.asg_common_tags, each.value.asg_tags))
    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = tag.value.propagate_at_launch
    }
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

resource "aws_eks_node_group" "eks" {
  for_each        = local.managed_node_groups != null ? local.managed_node_groups : {}

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = each.key
  node_role_arn   = each.value.iam_role_arn != null ? each.value.iam_role_arn : aws_iam_role.eks_worker.arn
  subnet_ids      = each.value.subnets_ids

  launch_template {
    id      = aws_launch_template.eks_node_groups[each.key].id
    version = "$Latest"
  }

  labels = each.value.k8s_labels != null ? each.value.k8s_labels : null

  dynamic "taint" {
    for_each  = each.value.k8s_taint != null ? each.value.k8s_taint : []
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

resource "aws_autoscaling_attachment" "autoscaling_attachment" {
  for_each = { for asg in local.config_autoscaling_attachment:  asg.autoscaling_group_name => asg }
  
  autoscaling_group_name = lookup(each.value, "autoscaling_group_name", null)
  lb_target_group_arn    = lookup(each.value, "lb_target_group_arn", null)
  
  depends_on = [
	aws_eks_node_group.eks
  ]
}