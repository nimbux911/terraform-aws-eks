variable "environment" {}
variable "cluster_name" {}
variable "cluster_version" {}
variable "vpc_id" {}
variable "subnets_ids" {}
variable "instance_type" {}
variable "max_size" {}
variable "min_size" {}
variable "max_pods_per_node"{}
variable "desired_capacity" {}
variable "eks_worker_ami_id" {}
variable "target_group_arns" {
    default = []
}

variable "health_check_type" {
    default = "EC2"
}

variable "eks_worker_max_pods_enabled" {
    default = false
}

variable "asg_tags" {
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

variable "add_configmap_roles" {
    default = []
}

variable "add_configmap_users" {
    default = []
}

variable "aws_auth_ignore_changes" {
    default = true
}

# ============================== helm releases ============================== #

# ================== ingress-nginx =================
variable "helm_ingress_ngnix_enabled" {
    default = false
}

variable "ingress_http_nodeport" {
    default = 32080
}

variable "ingress_https_nodeport" {
    default = 32443
}

# cluster-autoscaler
variable "helm_cluster_autoscaler_enabled" {
    default = false
}

# metrics-server
variable "helm_metrics_server_enabled" {
    default = false
}

# cert-manager
variable "helm_cert_manager_enabled" {
    default = false
}

# ================== loki-distributed ================= #
variable "helm_loki_enabled" {
    default = false
}

# loki - storage
variable "loki_storage_s3_bucket" {
    default = ""
}

variable "loki_s3_bucket_region" {
    default = ""
}

# loki - ingester
variable "loki_ingester_replicas" {
    default = 1
}

# loki - distributor
variable "loki_distributor_min_replicas" {
    default = 1
}

variable "loki_distributor_max_replicas" {
    default = 1
}

# loki - querier
variable "loki_querier_min_replicas" {
    default = 1
}

variable "loki_querier_max_replicas" {
    default = 1
}


# loki - query-frontend
variable "loki_query_frontend_min_replicas" {
    default = 1
}

variable "loki_query_frontend_max_replicas" {
    default = 1
}

# loki - gateway

variable "loki_gateway_enabled" {
    default = false
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

# loki - compactor

variable "loki_compactor_enabled" {
    default = true
}

# loki - index-gateway

variable "loki_index_gateway_enabled" {
    default = true
}

variable "loki_index_gateway_replicas" {
    default = 1
}

# ================== fluent-bit ================== #
variable "helm_fluent_bit_enabled" {
    default = false
}


# ================== prometheus ================== #
variable "helm_prometheus_enabled" {
    default = false
}

variable "prometheus_replicas" {
    default = 1
}

variable "prometheus_requests_cpu" {
    default = "200m"
}

variable "prometheus_requests_ram" {
    default = "1024Mi"
}

variable "prometheus_limits_cpu" {
    default = "500m"
}

variable "prometheus_limits_ram" {
    default = "2048Mi"
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

# ================== tempo ================== #
variable "helm_tempo_enabled" {
    default = false
}

# tempo - storage
variable "tempo_storage_s3_bucket" {
    default = ""
}

variable "tempo_s3_bucket_region" {
    default = ""
}

# tempo - gateway
variable "tempo_gateway_enabled" {
    default = false
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



## ============ grafana ============ #
#variable "grafana_enabled" {
#    default = false
#}
#
### grafana - dashboards
##variable "grafana_cluster_dashboard_enabled" {
##    default = true
##}
#
#variable "grafana_datasources" {
#    default = []
#}
#
## grafana - persistence
#variable "grafana_persistence_enabled" {
#    default = false
#}
#
#variable "grafana_persistence_storage_class_name" {
#    default = "gp2"
#}
#
#variable "grafana_persistence_size" {
#    default = "10Gi"
#}
#
## grafana - ingress
#variable "grafana_ingress_enabled" {
#    default = false
#}
#
#variable "grafana_ingress_host" {
#    default = ""
#}
#
## grafana - sidecard
#variable "grafana_sidecard_enabled" {
#    default = true
#}

# ============================== k8s manifests ============================== #

# open-telemetry
variable "k8s_opentelemetry_enabled" {
    default = false
}