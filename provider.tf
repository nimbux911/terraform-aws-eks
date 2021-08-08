data "external" "aws_iam_authenticator" {
  program = ["sh", "-c", "aws-iam-authenticator token -i ${aws_eks_cluster.main.name} | jq -r -c .status"]
}

data "aws_eks_cluster_auth" "main" {
  name = "${aws_eks_cluster.main.name}"
}

provider "kubernetes" {
  host                      = aws_eks_cluster.main.endpoint
  cluster_ca_certificate    = base64decode(aws_eks_cluster.main.certificate_authority.0.data)
  token                     = data.aws_eks_cluster_auth.main.token
  load_config_file          = false
  version                   = "~> 1.9"
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
      command     = "aws"
    }
  }
}