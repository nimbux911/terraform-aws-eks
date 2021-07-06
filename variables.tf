variable "environment" {}
variable "cluster_name" {}
variable "cluster_version" {}
variable "vpc_id" {}
variable "subnets_ids" {}
variable "instance_type" {}
variable "max_size" {}
variable "min_size" {}
variable "desired_capacity" {}
variable "eks_worker_ami_id" {}
variable "target_group_arns" {
    default = []
}

variable "health_check_type" {
    default = "EC2"
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

# ingress-nginx
variable "helm_ingress_ngnix_enabled" {
    default = false
}

# cluster-autoscaler
variable "helm_cluster_autoscaler_enabled" {
    default = false
}

# metrics-server
variable "helm_metrics_server_enabled" {
    default = false
}

# ================== loki-stack ================= #
variable "helm_loki_stack_enabled" {
    default = false
}

# ============ promtail ============ #
variable "promtail_enabled" {
    default = false
}

# ============ fluent-bit ============ #
variable "fluent_bit_enabled" {
    default = false
}


# ============ loki ============ #
variable "loki_enabled" {
    default = false
}

# loki - persistence
variable "loki_persistence_enabled" {
    default = false
}

variable "loki_persistence_storage_class_name" {
    default = "gp2"
}

variable "loki_persistence_size" {
    default = "10Gi"
}

# loki - ingress
variable "loki_ingress_enabled" {
    default = false
}

variable "loki_ingress_host" {
    default = ""
}

variable "loki_ingress_path" {
    default = "/"
}

# ============ grafana ============ #
variable "grafana_enabled" {
    default = false
}

## grafana - dashboards
#variable "grafana_cluster_dashboard_enabled" {
#    default = true
#}

variable "grafana_datasources" {
    default = []
}

# grafana - persistence
variable "grafana_persistence_enabled" {
    default = false
}

variable "grafana_persistence_storage_class_name" {
    default = "gp2"
}

variable "grafana_persistence_size" {
    default = "10Gi"
}

# grafana - ingress
variable "grafana_ingress_enabled" {
    default = false
}

variable "grafana_ingress_host" {
    default = ""
}

# grafana - sidecard
variable "grafana_sidecard_enabled" {
    default = true
}

# ============ prometheus ============ #
variable "prometheus_enabled" {
    default = false
}

# prometheus - alertmanager persistence
variable "prometheus_alertmanager_persistence_enabled" {
    default = false
}

variable "prometheus_alertmanager_persistence_storage_class_name" {
    default = "gp2"
}

variable "prometheus_alertmanager_persistence_size" {
    default = "10Gi"
}


# prometheus - server
variable "prometheus_server_persistence_enabled" {
    default = false
}

variable "prometheus_server_persistence_storage_class_name" {
    default = "gp2"
}

variable "prometheus_server_persistence_size" {
    default = "10Gi"
}
 
# prometheus - ingress
variable "prometheus_ingress_enabled" {
    default = false
}

variable "prometheus_ingress_host" {
    default = ""
}
