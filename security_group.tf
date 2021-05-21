resource "aws_security_group" "eks_master" {
    name        = "${var.cluster_name}-master"
    description = "Cluster communication with worker nodes"
    vpc_id      = var.vpc_id

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
  tags = merge({Name="${var.cluster_name}-master"}, var.eks_tags)
}

resource "aws_security_group_rule" "eks_master_api" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_master.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group" "eks_worker" {
  name        = "${var.cluster_name}-worker"
  description = "Security group for all worker nodes in the cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({Name="${var.cluster_name}-worker"}, var.eks_tags)
}

resource "aws_security_group_rule" "eks_worker_ingress_ssh" {
  description              = "Allow ssh connections"
  from_port                = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_worker.id
  cidr_blocks              = [data.aws_vpc.main.cidr_block]
  to_port                  = 22
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_worker_ingress_self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_worker.id
  source_security_group_id = aws_security_group.eks_worker.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_worker_ingress_cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_worker.id
  source_security_group_id = aws_security_group.eks_master.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_worker_ingress_https_from_master" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_worker.id
  source_security_group_id = aws_security_group.eks_master.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_master_ingress_https_from_workers" {
  description              = "Allow cluster control to receive communication from the worker Kubelets"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_master.id
  source_security_group_id = aws_security_group.eks_worker.id
  to_port                  = 443
  type                     = "ingress"
}