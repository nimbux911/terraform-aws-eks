# AWS Elastic Kubernetes Service Terraform module

Terraform module which creates EKS Cluster and dependent resources on AWS.

**For use this module is needed to install aws-iam-authenticator. You can do it following** [this link](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)


## Usage 1.0.0

### Elastic Kubernetes Service

EKS Cluster with ELB:

```hcl
module "eks_main" {
  source            = "git@bitbucket.org:somosmendel/eks.git?ref=v1.0.0"
  environment       = var.environment
  cluster_name      = "${var.environment}-eks-main"
  cluster_version   = var.eks_cluster_version
  
  vpc_id            = data.aws_vpc.main.id
  subnets_ids       = data.aws_subnet_ids.main_privates.ids

  target_group_arns = data.terraform_remote_state.elb_eks.outputs.target_group_arns 

  asg_tags          = var.asg_tags
  eks_tags          = var.eks_tags

  health_check_type = "ELB"

  min_size          = var.eks_asg_min_size
  max_size          = var.eks_asg_max_size
  desired_capacity  = var.eks_asg_desired_capacity
  instance_type     = var.eks_asg_instance_type
  eks_worker_ami_id = var.eks_worker_ami_id
}

resource "aws_security_group_rule" "elb_to_eks" {
  security_group_id         = module.eks_main.security_group_worker_arn
  type                      = "ingress"
  from_port                 = 32080
  to_port                   = 32080
  protocol                  = "tcp"
  source_security_group_id  = data.terraform_remote_state.elb_eks.outputs.lb_sg_id
}

```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name of the resources. | `string` | `""` | yes |
| cluster\_name | Cluster name | `string` | `""` | yes |
| cluster\_version | Kubernetes version of the cluster. | `string` | `""` | yes |
| vpc\_id | VPC ID where cluster will be deployed. | `string` | `""` | yes |
| subnet\_ids | Subnets ids from the VPC ID where the workers will be deployed. They must be, at least, from 2 differents AZs. | `list[string]` | `[]` | yes |
| instance\_type | Instance type of the EC2 workers. | `string` | `""` | yes |
| max\_size | Maximum size of the autoscaling for the worker nodes. | `string` | `""` | yes |
| min\_size | Minimum size of the autoscaling for the worker nodes. | `string` | `""` | yes |
| desired\_capacity | Desired size of the autoscaling for the worker nodes. | `string` | `""` | yes |
| eks\_worker\_ami\_id | AMI ID for the worker nodes | `string` | `""` | yes |
| target\_group\_arns | ARNs of the target groups for using the worker nodes behind of ELB | `list[string]` | `[]` | no |
| health\_check\_type | Health check type for the worker nodes. | `string` | `"EC2"` | no |
| asg\_tags | Tags to add to autoscaling group. | `list[map]` | `[]` | no |
| eks\_tags | Tags to add to all resources except the autoscaling group. | `map` | `{}` | no |
| eks\_api\_private | Defines it the Kubernetes API will be private or public. | `bool` | `false` | no |
| add\_configmap\_roles | Configmap yaml with the roles to be added to the aws-auth configmap. | `string` | `""` | no |


## Outputs

| Name | Description |
|------|-------------|
| security\_group\_worker\_arn | The ARN of the workers security group. |
| worker\_role\_arn | The ARN of the workers IAM Role. |
| worker\_role\_id | The ID of the workers IAM Role. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->