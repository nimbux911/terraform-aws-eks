variable "environment" {
    type = string
}
variable "cluster_name" {
    type = string
}
variable "cluster_version" {
    type = string
}
variable "vpc_id" {
    type = string
}
variable "subnets_ids" {
    type = list(string)
}
variable "max_pods_per_node"{
    type    = number
    default = null
}

variable "custom_node_groups"{
    type = list(object({
        name = string
        values = object({
            ami_id           = string,
            instance_type    = string,
            workers_public  = bool,
            extra_sg_ids     = optional(list(string)),
            instance_profile = optional(string),
            asg_min          = number,
            asg_max          = number,
            subnets_ids      = list(string),
            volume_type      = string,
            volume_size      = number,
            volume_iops      = optional(number),
            k8s_labels       = optional(map(string)),
            asg_tags         = optional(list(object({
                key                  = string,
                value                = string,
                propagate_at_launch  = bool}))),
            spot_nodes_enabled = optional(bool),
            spot_options       = optional(map(string))
        })
  }))
  default = null
}

variable "managed_node_groups"{
    type = list(object({
        name = string
        values = object({
            ami_id          = string,
            instance_type   = string,
            workers_public  = bool,
            extra_sg_ids    = optional(list(string)),
            iam_role_arn    = optional(string),
            asg_min         = number,
            asg_max         = number,
            subnets_ids     = list(string),
            volume_type     = string,
            volume_size     = number,
            volume_iops     = optional(number),
            k8s_labels      = optional(map(string)),
            k8s_taint       = optional(list(object({
                key     = string,
                value   = string,
                effect  = string
            })))
        })
  }))
    default = null
}

variable "k8s_auth_api" {
    default = "client.authentication.k8s.io/v1beta1"
}
variable "target_group_arns" {
    default = []
}

variable "health_check_type" {
    default = "EC2"
}

variable "on_demand_percentage_above_base_capacity" {
    description = "Percentage split between on-demand and Spot instances above the base on-demand capacity."
    default     = 100
}

variable "spot_allocation_strategy" {
    default = "capacity-optimized" 
}

variable "spot_instance_pools" {
    description = "Number of Spot pools per availability zone to allocate capacity. EC2 Auto Scaling selects the cheapest Spot pools and evenly allocates Spot capacity across the number of Spot pools that you specify. "
    default = 2
}

variable "eks_worker_max_pods_enabled" {
    default = false
}

variable "eks_worker_ssh_cidrs" {
    default = []
}

variable "eks_tags" {
    default = {}
}

variable "eks_api_private" {
    default = false
}

variable "enabled_cluster_log_types" {
    default = []
}

variable "enable_detailed_monitoring" {
    description = "If true, the launched EC2 instance will have detailed monitoring enabled."
    default = true
}

variable "add_configmap_roles" {
    default = []
}

variable "add_configmap_users" {
    default = []
}

variable "aws_auth_ignore_changes" {
    default = true
}

variable "cpu_credits" {
    default = "unlimited"
}

# ============================== EKS Addons ============================== #

variable "eks_addons" {
    default = {}
}

# ============================== IRSA ============================== #

variable "enable_irsa" {
  description = "Determines whether to create an OpenID Connect Provider for EKS to enable IRSA"
  type        = bool
  default     = true
}

variable "openid_connect_audiences" {
  description = "List of OpenID Connect audience client IDs to add to the IRSA provider"
  type        = list(string)
  default     = []
}

variable "custom_oidc_thumbprints" {
  description = "Additional list of server certificate thumbprints for the OpenID Connect (OIDC) identity provider's server certificate(s)"
  type        = list(string)
  default     = []
}

variable "create_ebs_csi_role" {
  description = "Indicates whether or not to create an IAM assumable role with oidc for EKS ebs-csi-controller. If true, the role will be created with the following name: '<cluster_name>-ebs-csi-controller'"
  type        = bool
  default     = false
}

# ============================== helm releases ============================== #
variable "k8s_image_registry" {
    default = "registry.k8s.io"
}
# ================== ingress-nginx =================
variable "helm_ingress_nginx_enabled" {
    default = false
}

variable "ingress_chart_version" {
    default = "4.0.18"
}

variable "ingress_additional_chart_version" {
    default = "4.0.18"
}

variable "ingress_http_nodeport" {
    default = 32080
}

variable "ingress_https_nodeport" {
    default = 32443
}

variable "ingress_https_traffic_enabled" {
    default = false
}

variable "ingress_service_monitor_enabled" {
    default = false
}

variable "ingress_requests_cpu" {
    default = "100m"
}

variable "ingress_requests_memory" {
    default = "90Mi"
}

variable "ingress_priority_class_name"{
    default = ""
}

variable "ingress_node_affinity" {
  default = {
    enabled     = "false",
    label_key   = null,
    label_value = null
  }
}

variable "ingress_custom_configuration" {
  type    = string
  default = null
}

variable "ingress_extra_args" {
  type    = map(string)
  default = {}
}

# ================== ingress-nginx-additional =================

variable "helm_ingress_nginx_additional_enabled" {
    default = false
}

variable "ingress_additional_http_nodeport" {
    default = 31080
}

variable "ingress_additional_https_nodeport" {
    default = 31443
}

variable "ingress_additional_https_traffic_enabled" {
    default = false
}

variable "ingress_additional_requests_cpu" {
    default = "100m"
}

variable "ingress_additional_requests_memory" {
    default = "90Mi"
}

variable "ingress_additional_priority_class_name"{
    default = ""
}

# cluster-autoscaler
variable "helm_cluster_autoscaler_enabled" {
    default = false
}

variable "cluster_autoscaler_chart_version" {
    default = "9.16.1"
}

variable "cluster_autoscaler_priority_class_name" {
    default = ""
}

variable "cluster_autoscaler_extra_helm_values" {
  default = ""
}

# metrics-server
variable "helm_metrics_server_enabled" {
    default = false
}

variable "metrics_server_chart_version" {
    default = "6.0.5"
}

variable "metrics_server_priority_class_name" {
    default = ""
}

# cert-manager
variable "helm_cert_manager_enabled" {
    default = false
}

variable "cert_manager_chart_version" {
    default = "1.6.1"
}

variable "cert_manager_priority_class_name" {
    default = ""
}

variable "ingress_additional_extra_args" {
  type    = map(string)
  default = {}
}

# ================== loki-distributed ================= #
variable "helm_loki_enabled" {
    default = false
}

variable "loki_chart_version" {
    default = "0.67.2"  
}

variable "loki_priority_class_name" {
    default = ""
}

# loki - storage
variable "loki_storage_s3_bucket" {
    default = ""
}

variable "loki_s3_bucket_region" {
    default = ""
}

variable "loki_logs_retention_enabled" {
    default = false
}

variable "loki_logs_retention" {
    default = "744h"
}

variable "loki_max_query_length" {
    default = "721h"
}

# loki - ingester
variable "loki_ingester_replicas" {
    default = 1
}

variable "loki_ingester_node_selector" {
    default = null
}

variable "loki_ingester_storage_class" {
    default = "gp2"
}

variable "loki_ingester_storage_size" {
    default = "10Gi"
}

variable "loki_ingester_requests_cpu" {
    default = null
}
variable "loki_ingester_requests_memory" {
    default = null
}
variable "loki_ingester_limits_cpu" {
    default = null
}
variable "loki_ingester_limits_memory" {
    default = null
}

# loki - distributor
variable "loki_distributor_min_replicas" {
    default = 1
}

variable "loki_distributor_node_selector" {
    default = null
}

variable "loki_distributor_requests_cpu" {
    default = null
}
variable "loki_distributor_requests_memory" {
    default = null
}
variable "loki_distributor_limits_cpu" {
    default = null
}
variable "loki_distributor_limits_memory" {
    default = null
}

variable "loki_distributor_max_replicas" {
    default = 1
}

# loki - querier
variable "loki_querier_min_replicas" {
    default = 1
}

variable "loki_querier_node_selector" {
    default = null
}

variable "loki_querier_max_replicas" {
    default = 1
}

variable "loki_querier_requests_cpu" {
    default = null
}
variable "loki_querier_requests_memory" {
    default = null
}
variable "loki_querier_limits_cpu" {
    default = null
}
variable "loki_querier_limits_memory" {
    default = null
}

# loki - query-frontend
variable "loki_query_frontend_min_replicas" {
    default = 1
}

variable "loki_query_frontend_node_selector" {
    default = null
}

variable "loki_query_frontend_max_replicas" {
    default = 1
}

variable "loki_query_frontend_requests_cpu" {
    default = null
}
variable "loki_query_frontend_requests_memory" {
    default = null
}
variable "loki_query_frontend_limits_cpu" {
    default = null
}
variable "loki_query_frontend_limits_memory" {
    default = null
}

# loki - gateway

variable "loki_gateway_enabled" {
    default = false
}

variable "loki_gateway_node_selector" {
    default = null
}

variable "loki_gateway_min_replicas" {
    default = 1
}

variable "loki_gateway_max_replicas" {
    default = 1
}

variable "loki_gateway_ingress_enabled" {
    default = false
}

variable "loki_gateway_ingress_host" {
    default = ""
}

variable "loki_gateway_ingress_path" {
    default = "/"
}

variable "loki_gateway_ingress_path_type" {
    default = "Prefix"
}

variable "loki_gateway_ingress_class_name" {
    default = "nginx"
}

variable "loki_gateway_requests_cpu" {
    default = null
}
variable "loki_gateway_requests_memory" {
    default = null
}
variable "loki_gateway_limits_cpu" {
    default = null
}
variable "loki_gateway_limits_memory" {
    default = null
}

# loki - compactor

variable "loki_compactor_enabled" {
    default = true
}

variable "loki_compactor_node_selector" {
    default = null
}

variable "loki_compactor_requests_cpu" {
    default = null
}
variable "loki_compactor_requests_memory" {
    default = null
}
variable "loki_compactor_limits_cpu" {
    default = null
}
variable "loki_compactor_limits_memory" {
    default = null
}

# loki - index-gateway

variable "loki_index_gateway_enabled" {
    default = true
}

variable "loki_index_gateway_node_selector" {
    default = null
}

variable "loki_index_gateway_replicas" {
    default = 1
}

variable "loki_index_gateway_storage_class" {
    default = "gp2"
}

variable "loki_index_gateway_storage_size" {
    default = "10Gi"
}

variable "loki_index_gateway_requests_cpu" {
    default = null
}
variable "loki_index_gateway_requests_memory" {
    default = null
}
variable "loki_index_gateway_limits_cpu" {
    default = null
}
variable "loki_index_gateway_limits_memory" {
    default = null
}

# ================== fluent-bit ================== #
variable "helm_fluent_bit_enabled" {
    default = false
}

variable "fluent_bit_chart_version" {
    default = "0.19.24"
}

variable "fluent_bit_priority_class_name" {
    default = ""
}


# ================== prometheus ================== #
variable "helm_prometheus_enabled" {
    default = false
}

variable "prometheus_chart_version" {
    default = "44.2.1"  
}

variable "prometheus_priority_class_name" {
    default = ""
}

variable "prometheus_node_selector" {
    default = null
}

variable "prometheus_replicas" {
    default = 1
}

variable "prometheus_requests_cpu" {
    default = null
}

variable "prometheus_requests_memory" {
    default = null
}

variable "prometheus_limits_cpu" {
    default = null
}

variable "prometheus_limits_memory" {
    default = null
}

variable "prometheus_ingress_enabled" {
    default = false
}

variable "prometheus_ingress_host" {
    default = ""
}

variable "prometheus_ingress_path" {
    default = "/"
}

variable "prometheus_ingress_path_type" {
    default = "Prefix"
}

variable "prometheus_ingress_class_name" {
    default = "nginx"
}

variable "prometheus_storage_class_name" {
    default = "gp2"
}

variable "prometheus_storage_size" {
    default = "20Gi"
}


variable "prometheus_metrics_retention" {
    default = "14d"
}

variable "prometheus_additional_scrape_configs" {
    default = ""
}

# ================== tempo ================== #
variable "helm_tempo_enabled" {
    default = false
}

variable "tempo_chart_version" {
    default = "0.17.1"  
}

variable "tempo_priority_class_name" {
    default = ""
}

# tempo - compactor
variable "tempo_compactor_requests_cpu" {
    default = null
}

variable "tempo_compactor_requests_memory" {
    default = null
}

variable "tempo_compactor_limits_cpu" {
    default = null
}

variable "tempo_compactor_limits_memory" {
    default = null
}

# tempo - distributor
variable "tempo_distributor_requests_cpu" {
    default = null
}

variable "tempo_distributor_requests_memory" {
    default = null
}

variable "tempo_distributor_limits_cpu" {
    default = null
}

variable "tempo_distributor_limits_memory" {
    default = null
}

# tempo - storage
variable "tempo_storage_s3_bucket" {
    default = ""
}

variable "tempo_s3_bucket_region" {
    default = ""
}

# tempo - ingester
variable "tempo_ingester_requests_cpu" {
    default = null
}

variable "tempo_ingester_requests_memory" {
    default = null
}

variable "tempo_ingester_limits_cpu" {
    default = null
}

variable "tempo_ingester_limits_memory" {
    default = null
}

# tempo - querier
variable "tempo_querier_requests_cpu" {
    default = null
}

variable "tempo_querier_requests_memory" {
    default = null
}

variable "tempo_querier_limits_cpu" {
    default = null
}

variable "tempo_querier_limits_memory" {
    default = null
}

# tempo - query-frontend
variable "tempo_query_frontend_requests_cpu" {
    default = null
}

variable "tempo_query_frontend_requests_memory" {
    default = null
}

variable "tempo_query_frontend_limits_cpu" {
    default = null
}

variable "tempo_query_frontend_limits_memory" {
    default = null
}

# tempo - gateway
variable "tempo_gateway_enabled" {
    default = false
}

variable "tempo_gateway_requests_cpu" {
    default = null
}

variable "tempo_gateway_requests_memory" {
    default = null
}

variable "tempo_gateway_limits_cpu" {
    default = null
}

variable "tempo_gateway_limits_memory" {
    default = null
}

variable "tempo_gateway_ingress_enabled" {
    default = false
}

variable "tempo_gateway_ingress_host" {
    default = ""
}

variable "tempo_gateway_ingress_path" {
    default = "/"
}

variable "tempo_ingress_path_type" {
    default = "Prefix"
}

variable "tempo_ingress_class_name" {
    default = "nginx"
}

# ============================== k8s manifests ============================== #

# open-telemetry
variable "k8s_opentelemetry_enabled" {
    default = false
}

# ============================== grafana ============================== #
variable "helm_grafana_enabled" {
    default = false
}

variable "grafana_chart_version" {
  default = "6.45.0"
}

variable "grafana_ingress_enabled" {
    default = false
}

variable "grafana_ingress_host" {
    default = ""
}

variable "grafana_ingress_path" {
    default = "/"
}

variable "grafana_ingress_path_type" {
    default = "Prefix"
}

variable "grafana_ingress_class_name" {
    default = "nginx"
}

variable "grafana_persistence_enabled" {
    default = false
}
variable "grafana_priority_class_name" {
    default = ""
}

variable "ingress_replicacount" {
    description = "Minimum Replicas count of ingress"
    type        = number
    default     = 1
}

variable "ingress_additional_replicacount" {
    description = "Minimum Replicas count of ingress additional"
    type        = number
    default     = 1
}