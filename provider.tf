
terraform {
  experiments = [module_variable_optional_attrs]
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=3.0, ~> 4.20"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.11"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.5.1"
    }
  }
}



provider "kubernetes" {
  host                      = aws_eks_cluster.main.endpoint
  cluster_ca_certificate    = base64decode(aws_eks_cluster.main.certificate_authority.0.data)
    exec {
      api_version = var.k8s_auth_api
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
      command     = "aws"
    }
}

provider "helm" {
  kubernetes {
    host                    = aws_eks_cluster.main.endpoint
    cluster_ca_certificate  = base64decode(aws_eks_cluster.main.certificate_authority.0.data)
    exec {
      api_version = var.k8s_auth_api
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
      command     = "aws"
    }
  }
}