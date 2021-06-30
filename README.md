# AWS Elastic Kubernetes Service Terraform module

Terraform module which creates EKS Cluster and dependent resources on AWS.

**For use this module is needed to install aws-iam-authenticator. You can do it following** [this link](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)


## Usage 2.0.0

### Elastic Kubernetes Service

EKS Cluster with ELB:

```hcl
locals {
  configmap_roles = [
    {
      "role_arn" = aws_iam_role.jobs_runner.arn 
      "k8s_user" = "jobs-runner"
      "k8s_groups" = [
        "system:masters"
        ]
      }
    ]

  configmap_users = [
    {
      "user_arn" = "arn:aws:iam::123456789123:user/demo"
      "k8s_user" = "demo"
      "k8s_groups" = [
        "system:masters"
        "system:developers"
        ]
      }
    ]

}


module "eks_main" {

  source              = "git@gitlab.com:nimbux/terraform-aws-eks.git?ref=v2.0.0"

  environment         = var.environment
  cluster_name        = "${var.environment}-eks-demo"
  cluster_version     = var.eks_cluster_version
  
  vpc_id              = data.terraform_remote_state.vpc_main.outputs.vpc_id
  subnets_ids         = data.terraform_remote_state.vpc_main.outputs.private_subnets_ids
  eks_api_private     = var.eks_api_private

  aws_auth_ignore_changes = false
  add_configmap_roles     = local.configmap_roles
  add_configmap_users     = local.configmap_users


  target_group_arns   = data.terraform_remote_state.elb_eks.outputs.target_group_arns

  health_check_type   = "ELB"  

  min_size            = var.eks_asg_min_size
  max_size            = var.eks_asg_max_size
  desired_capacity    = var.eks_asg_desired_capacity
  instance_type       = var.eks_asg_instance_type
  eks_worker_ami_id   = var.eks_worker_ami_id


  helm_ingress_ngnix_enabled      = true 
  helm_cluster_autoscaler_enabled = true
  helm_metrics_server_enabled     = true 
  helm_loki_stack_enabled         = true

  promtail_enabled         = true
  fluent_bit_enabled       = true
  loki_enabled             = true
  loki_persistence_enabled = true 
  loki_ingress_enabled     = true 
  loki_ingress_host        = "loki.domain.com" 
  loki_ingress_path        = "/"

  grafana_enabled             = true 
  grafana_persistence_enabled = true 
  grafana_ingress_enabled     = true 
  grafana_ingress_host        = "grafana.domain.com"    
  grafana_sidecard_enabled    = true

  prometheus_enabled                          = true 
  prometheus_alertmanager_persistence_enabled = true 
  prometheus_server_persistence_enabled       = true 
  prometheus_ingress_enabled                  = true 
  prometheus_ingress_host                     = "prometheus.domain.com"

}

```



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
| add\_configmap\_roles | List of maps with the information of the IAM roles to be added to aws-auth configmap. | `list[map]` | `[]` | no |
| add\_configmap\_users | List of maps with the information of the IAM users to be added to aws-auth configmap. | `list[map]` | `[]` | no |
| aws\_auth\_ignore\_changes | Set if aws-auth configmap will be managed by Terraform or ignored. | `bool` | `true` | no |
| helm\_ingress\_ngnix\_enabled | Set if ingress-nginx Helm chart will be installed on the cluster. | `bool` | `false` | no |
| helm\_cluster\_autoscaler\_enabled | Set if cluster-autoscaler Helm chart will be installed on the cluster. | `bool` | `false` | no |
| helm\_metrics\_server\_enabled | Set if metrics-server Helm chart will be installed on the cluster. | `bool` | `false` | no |
| helm\_loki\_stack\_enabled | Set if loki-stack Helm chart will be installed on the cluster. | `bool` | `false` | no |
| promtail\_enabled | Set if promtail will be enabled in the loki-stack. | `bool` | `false` | no |
| fluent\_bit\_enabled | Set if fluent-bit will be enabled in the loki-stack. | `bool` | `false` | no |
| loki\_enabled | Set if loki will be enabled in the loki-stack. | `bool` | `false` | no |
| loki\_persistence\_enabled | Set if loki pvc will be enabled in the loki-stack. | `bool` | `false` | no |
| loki\_persistence\_storage\_class\_name | Define loki pvc storageClass. | `string` | `gp2` | no |
| loki\_persistence\_size | Define loki pvc size. | `string` | `10Gi` | no |
| loki\_ingress\_enabled | Set if loki ingress will be enabled in the loki-stack. | `bool` | `false` | no |
| loki\_ingress\_host | Define host for loki ingress. | `string` | `""` | no |
| grafana\_enabled | Set if grafana will be enabled in the loki-stack. | `bool` | `false` | no |
| grafana\_persistence\_enabled | Set if grafana pvc will be enabled in the loki-stack. | `bool` | `false` | no |
| grafana\_persistence\_storage\_class\_name | Define grafana pvc storageClass. | `string` | `gp2` | no |
| grafana\_persistence\_size | Define grafana pvc size. | `string` | `10Gi` | no |
| grafana\_ingress\_enabled | Set if grafana ingress will be enabled in the loki-stack. | `bool` | `false` | no |
| grafana\_ingress\_host | Define host for grafana ingress. | `string` | `""` | no |
| grafana\_sidecard\_enabled | Set if grafana sidecard will be enabled in the loki-stack. | `bool` | `true` | no |
| prometheus\_enabled | Set if prometheus server will be enabled in the loki-stack. | `bool` | `false` | no |
| prometheus\_alertmanager\_enabled | Set if alertmanager will be enabled in the loki-stack. | `bool` | `false` | no |
| prometheus\_alertmanager\_persistence\_enabled | Set if alertmanager pvc will be enabled in the loki-stack. | `bool` | `false` | no |
| prometheus\_alertmanager\_persistence\_storage\_class\_name | Define alertmanager pvc storageClass. | `string` | `gp2` | no |
| prometheus\_alertmanager\_persistence\_size | Define alertmanager pvc size. | `string` | `10Gi` | no |
| prometheus\_server\_persistence\_enabled | Set if prometheus pvc will be enabled in the loki-stack. | `bool` | `false` | no |
| prometheus\_server\_persistence\_storage\_class\_name | Define prometheus pvc storageClass. | `string` | `gp2` | no |
| prometheus\_server\_persistence\_size | Define prometheus pvc size. | `string` | `10Gi` | no |
| prometheus\_server\_ingress\_enabled | Set if prometheus ingress will be enabled in the loki-stack. | `bool` | `false` | no |
| prometheus\_server\_ingress\_host | Define host for prometheus ingress. | `string` | `""` | no |


## Outputs

| Name | Description |
|------|-------------|
| security\_group\_worker\_arn | The ARN of the workers security group. |
| worker\_role\_arn | The ARN of the workers IAM Role. |
| worker\_role\_id | The ID of the workers IAM Role. |
