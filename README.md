# AWS Elastic Kubernetes Service Terraform module

Terraform module which creates EKS Cluster and dependent resources on AWS.

## Notice
#### This module install several Helm charts with limited inputs for their configuration, in order to keep it easy and simple. For a more accurate configuration we recommend to read their documentation and make your own installation of your desired Helm charts:
- [Metrics Server Helm chart](https://github.com/bitnami/charts/tree/master/bitnami/metrics-server/#installing-the-chart)
- [Ingress NGINX Helm Chart](https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx)
- [Cluster Autoscaler Helm Chart](https://github.com/kubernetes/autoscaler/tree/master/charts/cluster-autoscaler)
- [Cert Manager Helm Chart](https://github.com/cert-manager/cert-manager/tree/master/deploy/charts/cert-manager)
- [Kube Prometheus Stack Helm Chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
- [Loki Distributed Helm Chart](https://github.com/grafana/helm-charts/tree/main/charts/loki-distributed)
- [Fluent Bit Helm Chart](https://github.com/fluent/helm-charts/tree/main/charts/fluent-bit)
- [Tempo Distributed Helm Chart](https://github.com/grafana/helm-charts/tree/main/charts/tempo-distributed)


## Usage

#### Terraform required version >= 0.14.8

## Elastic Kubernetes Service

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
        "system:masters",
        "system:developers"
        ]
      }
    ]

}


module "eks_main" {
  source                                      = "github.com/nimbux911/terraform-aws-eks.git"
  environment                                 = "dev"
  cluster_name                                = "dev-eks-main"
  cluster_version                             = "1.21"
  vpc_id                                      = "vpc-abcd1234"
  subnets_ids                                 = ["subnet-abc1234", "subnet-efgh5678"]
  eks_api_private                             = true
  enabled_cluster_log_types                   = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  aws_auth_ignore_changes                     = false
  add_configmap_roles                         = local.configmap_roles
  target_group_arns                           = local.tg_arns
  eks_tags                                    = var.eks_tags
  health_check_type                           = "ELB"  

  managed_node_groups = [
    { 
      name    = "monitoring-${var.cluster_name}"
      values  = {
        ami_id            = var.eks_worker_ami_id,
        instance_type     = "m6a.large",
        asg_min           = 3,
        asg_max           = 4,
        subnets_ids       = ["subnet-abc1234", "subnet-efgh5678"],
        volume_type       = "gp3",
        volume_size       = 100,
        volume_iops       = 4000,
        k8s_labels        = {
          nodegroup       = "monitoring-${var.cluster_name}"
        }
      }
    }
  ]

  custom_node_groups = [
    {
      name    = "${var.environment}-${var.cluster_name}"
      values  = {
        ami_id            = var.eks_worker_ami_id,
        instance_type     = "t3.medium",
        asg_min           = 4,
        asg_max           = 8,
        subnets_ids       = ["subnet-abc1234", "subnet-efgh5678"],
        volume_type       = "gp2",
        volume_size       = 100,
        asg_tags          = var.asg_tags
        k8s_labels        = {
          nodegroup       = "${var.environment}-${var.cluster_name}"
        spot_nodes_enabled = true, // Just for custom node groups on Launch templates: https://docs.aws.amazon.com/eks/latest/APIReference/API_LaunchTemplateSpecification.html
        spot_options       = {
          max_price  = "0.0416" # t3.medium on-demand price
        }
      }
    }
  ]

  helm_ingress_nginx_enabled       = true 
  helm_cluster_autoscaler_enabled  = true
  helm_metrics_server_enabled      = true 
  helm_cert_manager_enabled        = true

  eks_addons = {
    vpc-cni = {
      version = "v1.10.2-eksbuild.1"
    },
    coredns = {
      version = "v1.8.3-eksbuild.1"
    },
    kube-proxy = {
      version = "v1.19.6-eksbuild.2"
    }
  }

# ================== loki-distributed ================= #
  helm_loki_enabled                     = true
  loki_storage_s3_bucket                = "my-bucket-loki-logs"
  loki_s3_bucket_region                 = "us-east-1"
  loki_ingester_replicas                = 3
  loki_ingester_node_selector           = { "eks\\.amazonaws\\.com/nodegroup" = "monitoring-${var.cluster_name}" }
  loki_distributor_min_replicas         = 2
  loki_distributor_node_selector        = { "eks\\.amazonaws\\.com/nodegroup" = "monitoring-${var.cluster_name}" }
  loki_distributor_max_replicas         = 4
  loki_querier_min_replicas             = 2
  loki_querier_max_replicas             = 4
  loki_querier_node_selector            = { "eks\\.amazonaws\\.com/nodegroup" = "monitoring-${var.cluster_name}" }
  loki_query_frontend_min_replicas      = 2
  loki_query_frontend_max_replicas      = 4
  loki_query_frontend_node_selector     = { "eks\\.amazonaws\\.com/nodegroup" = "monitoring-${var.cluster_name}" }
  loki_gateway_enabled                  = true
  loki_gateway_min_replicas             = 2
  loki_gateway_max_replicas             = 4
  loki_gateway_node_selector            = { "eks\\.amazonaws\\.com/nodegroup" = "monitoring-${var.cluster_name}" }
  loki_gateway_ingress_enabled          = true
  loki_gateway_ingress_host             = "loki.example.com"
  loki_compactor_enabled                = true
  loki_compactor_node_selector          = { "eks\\.amazonaws\\.com/nodegroup" = "monitoring-${var.cluster_name}" }
  loki_index_gateway_enabled            = true
  loki_index_gateway_replicas           = 1
  loki_index_gateway_node_selector      = { "eks\\.amazonaws\\.com/nodegroup" = "monitoring-${var.cluster_name}" }

# ================== fluent-bit ================== #
  helm_fluent_bit_enabled = true

# ================== prometheus ================== #
  helm_prometheus_enabled       = true
  prometheus_replicas           = 2
  prometheus_ingress_enabled    = true
  prometheus_ingress_host       = "prometheus.example.com"
  prometheus_requests_cpu       = "200m"
  prometheus_requests_memory    = "1024Mi"
  prometheus_limits_cpu         = "500m"
  prometheus_limits_memory      = "2048Mi"
  prometheus_node_selector      = { "eks\\.amazonaws\\.com/nodegroup" = "monitoring-${var.cluster_name}" }

# ================== tempo ================== #
  helm_tempo_enabled            = true
  tempo_storage_s3_bucket       = "my-bucket-tempo-traces"
  tempo_s3_bucket_region        = "us-east-1"
  tempo_gateway_enabled         = true
  tempo_gateway_ingress_enabled = true
  tempo_gateway_ingress_host    = "tempo.example.com"

# open-telemetry
  k8s_opentelemetry_enabled = true

}

```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name of the resources. | `string` | `""` | yes |
| cluster\_name | Cluster name | `string` | `""` | yes |
| cluster\_version | Kubernetes version of the cluster. | `string` | `""` | yes |
| managed\_node\_groups | AWS managed node groups configurations | `object(...)` | `null` | no |
| custom\_node\_groups | Custom node groups configurations | `object(...)` | `null` | no |
| k8s\_auth\_api | Kubernetes authentication API for Terraform providers. | `string` | `client.authentication.k8s.io/v1beta1` | no |
| vpc\_id | VPC ID where cluster will be deployed. | `string` | `""` | yes |
| subnets\_ids | Subnets ids from the VPC ID where the workers will be deployed. They must be, at least, from 2 differents AZs. | `list[string]` | `[]` | yes |
| max\_pods\_per\_node | Max pods per Kubernetes worker node. | `string` | `"100"` | no |
| target\_group\_arns | ARNs of the target groups for using the worker nodes behind of ELB | `list[string]` | `[]` | no |
| health\_check\_type | Health check type for the worker nodes. | `string` | `"EC2"` | no |
| eks\_tags | Tags to add to all resources except the autoscaling group. | `map` | `{}` | no |
| eks\_api\_private | Defines it the Kubernetes API will be private or public. | `bool` | `false` | no |
| eks\_addons | Adds EKS addons. | `map(map(string))` | `{}` | no |
| add\_configmap\_roles | List of maps with the information of the IAM roles to be added to aws-auth configmap. | `list[map]` | `[]` | no |
| add\_configmap\_users | List of maps with the information of the IAM users to be added to aws-auth configmap. | `list[map]` | `[]` | no |
| aws\_auth\_ignore\_changes | Set if aws-auth configmap will be managed by Terraform or ignored. | `bool` | `true` | no |
| eks\_worker\_max\_pods\_enabled | Enable --max-pods flag in workers bootstrap | `bool` | `false` | no |
| eks\_worker\_ssh\_cidrs | Add SSH ingress rule to eks workers | `list` | `[]` | no |
| enabled\_cluster\_log\_types | Enable CloudWatch Logs for control plane components | `list[string]` | `[]` | no |
| helm\_ingress\_nginx\_enabled | Set if ingress-nginx Helm chart will be installed on the cluster. | `bool` | `false` | no |
| helm\_ingress\_nginx\_additional\_enabled | Set if additional ingress-nginx Helm chart will be installed on the cluster. | `bool` | `false` | no |
| ingress\_http\_nodeport | Set port for ingress http nodePort | `int` | `32080` | no |
| ingress\_https\_nodeport | Set port for ingress https nodePort | `int` | `32443` | no |
| ingress\_https\_traffic\_enabled | Set https traffic for ingress | `bool` | `false` | no | 
| ingress\_requests\_cpu | Set how much cpu will be assigned to the request | `string` | `100m` | no | 
| ingress\_requests\_memory | Set how much memory will be assigned to the request | `string` | `90Mi` | no |
| ingress\_additional\_http\_nodeport | Set port for additional ingress http nodePort | `int` | `31080` | no |
| ingress\_additional\_https\_nodeport | Set port for additional ingress https nodePort | `int` | `31443` | no |
| ingress\_additional\_https\_traffic\_enabled | Set https traffic for additional ingress | `bool` | `false` | no | 
| ingress\_service\_monitor\_enabled | Enable serviceMonitor for ingress-nginx helm chart | `bool` | `false` | no |
| ingress\_additional\_requests\_cpu | Set how much cpu will be assigned to the request | `string` | `100m` | no | 
| ingress\_additional\_requests\_memory | Set how much memory will be assigned to the request | `string` | `90Mi` | no |
| helm\_cluster\_autoscaler\_enabled | Set if cluster-autoscaler Helm chart will be installed on the cluster. | `bool` | `false` | no |
| helm\_metrics\_server\_enabled | Set if metrics-server Helm chart will be installed on the cluster. | `bool` | `false` | no |
| helm\_cert\_manager\_enabled | Set if cert-manager helm chart will be installed on the cluster | `bool` | `false` | no |
| helm\_loki\_enabled | Set if loki-stack Helm chart will be installed on the cluster. | `bool` | `false` | no |
| loki\_storage\_s3\_bucket | s3 bucket for loki logs | `string` | `""` | yes |
| loki\_s3\_bucket\_region | s3 bucket for loki logs region | `string` | `""` | yes |
| loki\_logs\_retention\_enabled | Enable logs retention. If s3 storage never stop growing | `bool` | `false` | no |
| loki\_logs\_retention | Set logs retention period | `string` | `744h` | no |
| loki\_ingester\_replicas | Loki ingester replicas | `int` | `1` | no | 
| loki\_ingester\_node\_selector | Loki ingester nodeSelector | `map{}` | `null` | no | 
| loki\_ingester\_storage\_class | storageClass for ingesters pv | `string` | `gp2` | no |
| loki\_ingester\_storage\_size | size of ingesters pv | `string` | `10Gi` | no |
| loki\_ingester\_requests\_cpu | resources config for kubernetes pod | `string` | `null` | no |
| loki\_ingester\_requests\_memory | resources config for kubernetes pod | `string` | `null` | no |
| loki\_ingester\_limits\_cpu | resources config for kubernetes pod | `string` | `null` | no |
| loki\_ingester\_limits\_memory | resources config for kubernetes pod | `string` | `null` | no |
| loki\_distributor\_node\_selector | Loki distributor nodeSelector | `map{}` | `null` | no | 
| loki\_distributor\_min\_replicas | loki distributor hpa min replicas | `int` | `1` | no |
| loki\_distributor\_requests\_cpu | resources config for kubernetes pod | `string` | `null` | no |
| loki\_distributor\_requests\_memory | resources config for kubernetes pod | `string` | `null` | no |
| loki\_distributor\_limits\_cpu | resources config for kubernetes pod | `string` | `null` | no |
| loki\_distributor\_limits\_memory | resources config for kubernetes pod | `string` | `null` | no |
| loki\_distributor\_max\_replicas | loki distributor hpa max replicas | `int` | `1` | no |
| loki\_querier\_node\_selector | Loki querier nodeSelector | `map{}` | `null` | no |
| loki\_querier\_min\_replicas | loki querier hpa min replicas | `int` | `1` | no |
| loki\_querier\_max\_replicas | loki querier hpa max replicas | `int` | `1` | no |
| loki\_querier\_requests\_cpu | resources config for kubernetes pod | `string` | `null` | no |
| loki\_querier\_requests\_memory | resources config for kubernetes pod | `string` | `null` | no |
| loki\_querier\_limits\_cpu | resources config for kubernetes pod | `string` | `null` | no |
| loki\_querier\_limits\_memory | resources config for kubernetes pod | `string` | `null` | no |
| loki\_query\_frontend\_node\_selector | Loki query-frontend nodeSelector | `map{}` | `null` | no | 
| loki\_query\_frontend\_min\_replicas | loki query-frontend hpa min replicas | `int` | `1` | no |
| loki\_query\_frontend\_max\_replicas | loki query-frontend hpa max replicas | `int` | `1` | no |
| loki\_query\_frontend\_requests\_cpu | resources config for kubernetes pod | `string` | `null` | no |
| loki\_query\_frontend\_requests\_memory | resources config for kubernetes pod | `string` | `null` | no |
| loki\_query\_frontend\_limits\_cpu | resources config for kubernetes pod | `string` | `null` | no |
| loki\_query\_frontend\_limits\_memory | resources config for kubernetes pod | `string` | `null` | no |
| loki\_max\_query\_length | The limit to length of chunk store queries | `string` | `721h` | no |
| loki\_gateway\_enabled | Enable loki gateway | `bool` | `false` | no |
| loki\_gateway\_node\_selector | Loki gateway nodeSelector | `map{}` | `null` | no | 
| loki\_gateway\_min\_replicas | loki gateway hpa min replicas | `int` | `1` | no |
| loki\_gateway\_max\_replicas | loki gateway hpa max replicas | `int` | `1` | no |
| loki\_gateway\_ingress\_enabled | Enable ingress for loki gateway | `bool` | `false` | no |
| loki\_gateway\_ingress\_host | Host for ingress rule | `string` | `""` | no |
| loki\_gateway\_ingress\_path | Path for ingress rule | `string` | `/` | no |
| loki\_gateway\_ingress\_path\_type | Path type for ingress rule  | `string` | `Prefix` | no |
| loki\_gateway\_ingress\_class\_name | Set ingress class name | `string` | `nginx` | no |
| loki\_gateway\_requests\_cpu | resources config for kubernetes pod | `string` | `null` | no |
| loki\_gateway\_requests\_memory | resources config for kubernetes pod | `string` | `null` | no |
| loki\_gateway\_limits\_cpu | resources config for kubernetes pod | `string` | `null` | no |
| loki\_gateway\_limits\_memory | resources config for kubernetes pod | `string` | `null` | no |
| loki\_compactor\_enabled | Enable loki compactor | `bool` | `false` | no |
| loki\_compactor\_node\_selector | Loki compactor nodeSelector | `map{}` | `null` | no | 
| loki\_compactor\_requests\_cpu | resources config for kubernetes pod | `string` | `null` | no |
| loki\_compactor\_requests\_memory | resources config for kubernetes pod | `string` | `null` | no |
| loki\_compactor\_limits\_cpu | resources config for kubernetes pod | `string` | `null` | no |
| loki\_compactor\_limits\_memory | resources config for kubernetes pod | `string` | `null` | no |
| loki\_index\_gateway\_enabled | Enable loki index gateway | `bool` | `false` | no |
| loki\_index\_gateway\_node\_selector | Loki _index gateway nodeSelector | `map{}` | `null` | no | 
| loki\_index\_gateway\_replicas | Set loki index gateway replicas | `int` | `1` | no |
| loki\_index\_gateway\_storage\_class | storageClass for index gateway pv | `string` | `gp2` | no |
| loki\_index\_gateway\_storage\_size | storage size for index gateway pv | `string` | `10Gi` | no |
| loki\_index\_gateway\_requests\_cpu | resources config for kubernetes pod | `string` | `null` | no |
| loki\_index\_gateway\_requests\_memory | resources config for kubernetes pod | `string` | `null` | no |
| loki\_index\_gateway\_limits\_cpu | resources config for kubernetes pod | `string` | `null` | no |
| loki\_index\_gateway\_limits\_memory | resources config for kubernetes pod | `string` | `null` | no |
| helm\_fluent\_bit\_enabled | install fluent-bit helm chart | `bool` | `false` | no |
| k8s\_opentelemetry\_enabled | install opentelemetry manifests | `bool` | `false` | no |
| helm\_prometheus\_enabled | install kube-prometheus-stack helm chart | `bool` | `false` | no |
| prometheus\_node\_selector | Prometheus components nodeSelector | `map{}` | `null` | no | 
| prometheus\_replicas | prometheus server replicas | `int` | `1` | no |
| prometheus\_requests\_cpu | resources config for kubernetes pod | `string` | `null` | no |
| prometheus\_requests\_memory | resources config for kubernetes pod | `string` | `null` | no |
| prometheus\_limits\_cpu | resources config for kubernetes pod | `string` | `null` | no |
| prometheus\_limits\_memory | resources config for kubernetes pod | `string` | `null` | no |
| prometheus\_ingress\_enabled | Enable ingress for prometheus server | `bool` | `false` | no |
| prometheus\_ingress\_host | Host for ingress rule | `string` | `""` | no |
| prometheus\_ingress\_path | Path for ingress rule | `string` | `/` | no |
| prometheus\_ingress\_path\_type | Path type for ingress rule | `string` | `Prefix` | no |
| prometheus\_ingress\_class\_name | Prometheus Ingress className | `string` | `nginx` | no |
| prometheus\_storage\_class\_name | Prometheus storage className for pv | `string` | `gp2` | no |
| prometheus\_storage\_size | Prometheus storage size | `string` | `20Gi` | no |
| prometheus\_metrics\_retention | Prometheus metrics period retention | `string` | `14d` | no |
| helm\_tempo\_enabled | Install tempo-distributed helm chart | `bool` | `false` | no |
| tempo\_compactor\_requests\_cpu | resources config for kubernetes pod | `string` | `null` | no |
| tempo\_compactor\_requests\_memory | resources config for kubernetes pod | `string` | `null` | no |
| tempo\_compactor\_limits\_cpu | resources config for kubernetes pod | `string` | `null` | no |
| tempo\_compactor\_limits\_memory | resources config for kubernetes pod | `string` | `null` | no |
| tempo\_distributor\_requests\_cpu | resources config for kubernetes pod | `string` | `null` | no |
| tempo\_distributor\_requests\_memory | resources config for kubernetes pod | `string` | `null` | no |
| tempo\_distributor\_limits\_cpu | resources config for kubernetes pod | `string` | `null` | no |
| tempo\_distributor\_limits\_memory | resources config for kubernetes pod | `string` | `null` | no |
| tempo\_storage\_s3\_bucket | s3 bucket for tempo traces | `string` | `""` | no |
| tempo\_s3\_bucket\_region | s3 bucket regino for tempo traces | `string` | `""` | no |
| tempo\_ingester\_requests\_cpu | resources config for kubernetes pod | `string` | `null` | no |
| tempo\_ingester\_requests\_memory | resources config for kubernetes pod | `string` | `null` | no |
| tempo\_ingester\_limits\_cpu | resources config for kubernetes pod | `string` | `null` | no |
| tempo\_ingester\_limits\_memory | resources config for kubernetes pod | `string` | `null` | no |
| tempo\_querier\_requests\_cpu | resources config for kubernetes pod | `string` | `null` | no |
| tempo\_querier\_requests\_memory | resources config for kubernetes pod | `string` | `null` | no |
| tempo\_querier\_limits\_cpu | resources config for kubernetes pod | `string` | `null` | no |
| tempo\_querier\_limits\_memory | resources config for kubernetes pod | `string` | `null` | no |
| tempo\_query\_frontend\_requests\_cpu | resources config for kubernetes pod | `string` | `null` | no |
| tempo\_query\_frontend\_requests\_memory | resources config for kubernetes pod | `string` | `null` | no |
| tempo\_query\_frontend\_limits\_cpu | resources config for kubernetes pod | `string` | `null` | no |
| tempo\_query\_frontend\_limits\_memory | resources config for kubernetes pod | `string` | `null` | no |
| tempo\_gateway\_enabled | enable tempo gateway | `bool` | `false` | no |
| tempo\_gateway\_requests\_cpu | resources config for kubernetes pod | `string` | `null` | no |
| tempo\_gateway\_requests\_memory | resources config for kubernetes pod | `string` | `null` | no |
| tempo\_gateway\_limits\_cpu | resources config for kubernetes pod | `string` | `null` | no |
| tempo\_gateway\_limits\_memory | resources config for kubernetes pod | `string` | `null` | no |
| tempo\_gateway\_ingress\_enabled | Enable ingress for tempo gateway | `bool` | `false` | no |
| tempo\_gateway\_ingress\_host | Host for ingress rule | `string` | `""` | no |
| tempo\_gateway\_ingress\_path | Path for ingress rule | `string` | `/` | no |
| tempo\_ingress\_path\_type | Path type for ingress rule | `string` | `Prefix` | no |
| tempo\_ingress\_class\_name | ingress className | `string` | `nginx` | no |

## Outputs

| Name | Description |
|------|-------------|
| security\_group\_worker\_arn | The ARN of the workers security group. |
| worker\_role\_arn | The ARN of the workers IAM Role. |
| worker\_role\_id | The ID of the workers IAM Role. |
| eks\_certificate\_authority | Cluster's certificate authority. |
| eks\_endpoint | Cluster's endpoint. |
