locals {
  eks_worker_userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.main.endpoint}' --b64-cluster-ca '${aws_eks_cluster.main.certificate_authority.0.data}' '${aws_eks_cluster.main.name}' --use-max-pods false --kubelet-extra-args '--max-pods=${var.max_pods_per_node}'
USERDATA
}

resource "aws_key_pair" "eks" {
  key_name   = aws_eks_cluster.main.name
  public_key = base64decode(aws_ssm_parameter.eks_public_key.value)
  tags = var.eks_tags
}
 
resource "aws_launch_configuration" "eks" {
  iam_instance_profile        = aws_iam_instance_profile.eks_worker.name
  image_id                    = var.eks_worker_ami_id
  instance_type               = var.instance_type
  name_prefix                 = aws_eks_cluster.main.name
  security_groups             = [aws_security_group.eks_worker.id]
  user_data_base64            = base64encode(local.eks_worker_userdata)
  key_name                    = aws_key_pair.eks.key_name
 
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "eks" {
  desired_capacity     = var.desired_capacity
  launch_configuration = aws_launch_configuration.eks.id
  max_size             = var.max_size
  min_size             = var.min_size
  name                 = var.cluster_name
  vpc_zone_identifier  = var.subnets_ids
  target_group_arns    = var.target_group_arns
  health_check_type    = var.health_check_type

  tags = concat(
    [
      {
        "key"                 = "Name"
        "value"               = var.cluster_name
        "propagate_at_launch" = true
      },
      {
        "key"                 = "kubernetes.io/cluster/${aws_eks_cluster.main.name}"
        "value"               = "owned"
        "propagate_at_launch" = true
      },
    ],
    var.asg_tags,
  )
  
}
