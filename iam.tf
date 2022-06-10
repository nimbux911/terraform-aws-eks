# EKS Master

resource "aws_iam_role" "eks_master" {
  name = "${var.environment}-eks-master"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = var.eks_tags

}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_master.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_master.name
}

# EKS Worker Nodes

resource "aws_iam_role" "eks_worker" {
  name = "${var.environment}-eks-worker"
 
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = var.eks_tags

}
 
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_worker.name
}
 
resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_worker.name
}
 
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_worker.name
}

resource "aws_iam_role_policy" "eks_worker_cloudwatch" {
  name = "${var.environment}-eks-worker-cloudwatch"
  role = aws_iam_role.eks_worker.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy" "eks_worker_s3_loki" {
  count = var.helm_loki_enabled ? 1 : 0
  name = "loki_s3_permissions"
  role = aws_iam_role.eks_worker.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "s3:ListBucket",
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        "Effect": "Allow",
        "Resource": [
          "arn:aws:s3:::${var.loki_storage_s3_bucket}",
          "arn:aws:s3:::${var.loki_storage_s3_bucket}/*"
          ]
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy" "eks_worker_s3_tempo" {
  count = var.helm_tempo_enabled ? 1 : 0
  name = "tempo_s3_permissions"
  role = aws_iam_role.eks_worker.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "s3:ListBucket",
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        "Effect": "Allow",
        "Resource": [
          "arn:aws:s3:::${var.tempo_storage_s3_bucket}",
          "arn:aws:s3:::${var.tempo_storage_s3_bucket}/*"
          ]
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy" "cluster_autoscaler" {
  count = var.helm_cluster_autoscaler_enabled ? 1 : 0
  name = "cluster_autoscaler"
  role = aws_iam_role.eks_worker.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ],
        "Effect": "Allow",
        "Resource": "${aws_autoscaling_group.eks_ignore_desired_capacity[0].arn}"
      },
      {
        "Action": [
          "autoscaling:DescribeTags",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "ec2:DescribeLaunchTemplateVersions"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  }
  EOF
}

resource "aws_iam_instance_profile" "eks_worker" {
  name = "${var.environment}-eks-worker"
  role = aws_iam_role.eks_worker.name
}