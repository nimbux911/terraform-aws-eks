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
          "autoscaling:DescribeTags",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ],
        "Effect": "Allow",
        "Resource": "*"
       },
      {
        "Effect": "Allow",
        "Action": [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeImages",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ],
        "Resource": ["*"]
      }
    ]
  }
  EOF
}

resource "aws_iam_instance_profile" "eks_worker" {
  name = "${var.environment}-eks-worker"
  role = aws_iam_role.eks_worker.name
}


module "ebs_csi_controller_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.17.0"
  create_role                   = var.enable_irsa && var.create_ebs_csi_role ? true : false
  role_name                     = "${var.cluster_name}-ebs-csi-controller"
  provider_url                  = replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.ebs_csi_controller[0].arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]

depends_on = [
  aws_iam_policy.ebs_csi_controller
]
}

resource "aws_iam_policy" "ebs_csi_controller" {
  count       = var.enable_irsa && var.create_ebs_csi_role ? 1 : 0
  name_prefix = "ebs-csi-controller"
  description = "EKS ebs-csi-controller policy for cluster ${var.cluster_name}"
  policy      = file("${path.module}/resources/policies/ebs_csi_controller_iam_policy.json")
}
