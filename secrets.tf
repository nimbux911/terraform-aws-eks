resource "tls_private_key" "eks" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_ssm_parameter" "eks_public_key" {
  name  = "${var.cluster_name}-public-key"
  type  = "SecureString"
  value = base64encode(tls_private_key.eks.public_key_openssh)
  lifecycle {
    ignore_changes = [value]
  }

  tags = var.eks_tags
}

resource "aws_ssm_parameter" "eks_private_key" {
  name  = "${var.cluster_name}-private-key"
  type  = "SecureString"
  tier  = "Advanced"
  value = base64encode(tls_private_key.eks.private_key_pem)
  lifecycle {
    ignore_changes = [value]
  }

  tags = var.eks_tags
}