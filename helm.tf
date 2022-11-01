
# ========================= core charts ========================= #

resource "helm_release" "ingress_nginx" {
  count             = var.helm_ingress_ngnix_enabled ? 1 : 0
  name              = "ingress-nginx"
  namespace         = "ingress-nginx"
  create_namespace  = true
  repository        = "https://kubernetes.github.io/ingress-nginx"
  chart             = "ingress-nginx"
  version           = "4.0.18"

  values            = [
    file("${path.module}/helm-values/ingress-nginx.yaml")
  ]

  set {
    name  = "controller.metrics.enabled"
    value = var.ingress_service_monitor_enabled
  }

  set {
    name  = "controller.metrics.serviceMonitor.enabled"
    value = var.ingress_service_monitor_enabled
  }


  set {
    name  = "controller.service.nodePorts.http"
    value = var.ingress_http_nodeport
  }

  set {
    name  = "controller.service.nodePorts.https"
    value = var.ingress_https_nodeport
  }

  depends_on = [time_sleep.wait_20_seconds]

}

resource "helm_release" "cluster_autoscaler" {
  count      = var.helm_cluster_autoscaler_enabled ? 1 : 0
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.16.1"

  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "awsRegion"
    value = data.aws_region.current.name
  }

  depends_on = [time_sleep.wait_20_seconds]

}


resource "helm_release" "metrics_server" {
  count      = var.helm_metrics_server_enabled ? 1 : 0
  name       = "metrics-server"
  namespace  = "kube-system"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "metrics-server"
  version    = "5.11.3"

  set {
    name  = "hostNetwork"
    value = true
  }

  set {
    name  = "apiService.create"
    value = true
  }

  depends_on = [time_sleep.wait_20_seconds]

}

resource "helm_release" "cert_manager" {
  count             = var.helm_cert_manager_enabled || var.k8s_opentelemetry_enabled ? 1 : 0
  name              = "cert-manager"
  namespace         = "cert-manager"
  repository        = "https://charts.jetstack.io"
  chart             = "cert-manager"
  create_namespace  = true
  version           = "1.6.1"

  set {
    name  = "installCRDs"
    value = true
  }

  depends_on = [time_sleep.wait_20_seconds]

}

# ========================= monitoring charts ========================= #

resource "helm_release" "prometheus_stack" {
  count             = var.helm_prometheus_enabled ? 1 : 0
  name              = "prometheus-stack"
  namespace         = "monitoring"
  create_namespace  = true
  repository        = "https://prometheus-community.github.io/helm-charts"
  chart             = "kube-prometheus-stack"
  version           = "35.0.3"
  dependency_update = true
  timeout           = 600

  set {
    name = "grafana.enabled"
    value = false
  }

  set {
    name  = "prometheus.prometheusSpec.replicas"
    value = var.prometheus_replicas
  }  

  set {
    name  = "prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues"
    value = false
  }

  set {
    name  = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues"
    value = false
  }  

  set {
    name = "prometheus-node-exporter.nodeSelector.eks\\.amazonaws\\.com/compute-type"
    value = "ec2"
  }

  dynamic "set" {
    for_each = var.prometheus_node_selector != null ? var.prometheus_node_selector : {}
    content {
      name  = "alertmanager.alertmanagerSpec.nodeSelector.${set.key}"
      value = set.value
    }
  }

  dynamic "set" {
    for_each = var.prometheus_node_selector != null ? var.prometheus_node_selector : {}
    content {
      name  = "prometheus.prometheusSpec.nodeSelector.${set.key}"
      value = set.value
    }
  }

  dynamic "set" {
    for_each = var.prometheus_node_selector != null ? var.prometheus_node_selector : {}
    content {
      name  = "prometheusOperator.nodeSelector.${set.key}"
      value = set.value
    }
  }


  dynamic "set" {
    for_each = var.prometheus_requests_cpu != null ? ["do it"] : []
    content {
      name  = "prometheus.prometheusSpec.resources.requests.cpu"
      value = var.prometheus_requests_cpu
    }
  }

  dynamic "set" {
    for_each = var.prometheus_requests_memory != null ? ["do it"] : []
    content {
      name  = "prometheus.prometheusSpec.resources.requests.memory"
      value = var.prometheus_requests_memory
    }
  }

  dynamic "set" {
    for_each = var.prometheus_limits_cpu != null ? ["do it"] : []
    content {
      name  = "prometheus.prometheusSpec.resources.limits.cpu"
      value = var.prometheus_limits_cpu
    }
  }

  dynamic "set" {
    for_each = var.prometheus_limits_memory != null ? ["do it"] : []
    content {
      name  = "prometheus.prometheusSpec.resources.limits.memory"
      value = var.prometheus_limits_memory
    }
  }

  set {
    name  = "prometheus.prometheusSpec.retention"
    value = var.prometheus_metrics_retention
  }  

  set {
    name  = "prometheus.ingress.enabled"
    value = var.prometheus_ingress_enabled
  }  

  set {
    name  = "prometheus.ingress.hosts[0]"
    value = var.prometheus_ingress_host
  }  

  set {
    name  = "prometheus.ingress.paths[0]"
    value = var.prometheus_ingress_path
  }  

  set {
    name  = "prometheus.ingress.pathType"
    value = var.prometheus_ingress_path_type
  }  

  set {
    name  = "prometheus.ingress.ingressClassName"
    value = var.prometheus_ingress_class_name
  }  

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName"
    value = var.prometheus_storage_class_name
  }  


  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = var.prometheus_storage_size
  }  


  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.accessModes[0]"
    value = "ReadWriteOnce"
  }  


  depends_on = [time_sleep.wait_20_seconds]

}

# ================== loki-distributed ================== #

resource "helm_release" "loki_distributed" {
  count             = var.helm_loki_enabled ? 1 : 0
  name              = "loki-distributed"
  namespace         = "monitoring"
  create_namespace  = true
  repository        = "https://grafana.github.io/helm-charts"
  chart             = "loki-distributed"
  version           = "0.48.3"
  dependency_update = true
  timeout           = 600

  values            = [
    file("${path.module}/helm-values/loki-distributed.yaml")
  ]

  # loki - storage
  set {
    name  = "loki.storageConfig.aws.s3"
    value = "s3://${var.loki_s3_bucket_region}/${var.loki_storage_s3_bucket}"
  } 

  set {
    name  = "loki.structuredConfig.compactor.retention_enabled"
    value = var.loki_logs_retention_enabled
  }

  set {
    name  = "loki.structuredConfig.limits_config.retention_period"
    value = var.loki_logs_retention
  } 

  set {
    name  = "loki.structuredConfig.limits_config.max_query_length"
    value = var.loki_max_query_length
  }

  # loki - ingester

  dynamic "set" {
    for_each = var.loki_ingester_node_selector != null ? var.loki_ingester_node_selector : {}
    content {
      name  = "ingester.nodeSelector.${set.key}"
      value = set.value
    }
  }


  set {
    name  = "ingester.replicas"
    value = var.loki_ingester_replicas
  }

  set {
    name  = "ingester.persistence.enabled"
    value = true
  }

  set {
    name  = "ingester.persistence.storageClass"
    value = var.loki_ingester_storage_class
  }

  set {
    name  = "ingester.persistence.size"
    value = var.loki_ingester_storage_size
  }

  dynamic "set" {
    for_each = var.loki_ingester_requests_cpu != null ? ["do it"] : []
    content {
      name  = "ingester.resources.requests.cpu"
      value = var.loki_ingester_requests_cpu
    }
  }

  dynamic "set" {
    for_each = var.loki_ingester_requests_memory != null ? ["do it"] : []
    content {
      name  = "ingester.resources.requests.memory"
      value = var.loki_ingester_requests_memory
    }
  }

  dynamic "set" {
    for_each = var.loki_ingester_limits_cpu != null ? ["do it"] : []
    content {
      name  = "ingester.resources.limits.cpu"
      value = var.loki_ingester_limits_cpu
    }
  }

  dynamic "set" {
    for_each = var.loki_ingester_limits_memory != null ? ["do it"] : []
    content {
      name  = "ingester.resources.limits.memory"
      value = var.loki_ingester_limits_memory
    }
  }

  # loki - distributor

  dynamic "set" {
    for_each = var.loki_distributor_node_selector != null ? var.loki_distributor_node_selector : {}
    content {
      name  = "distributor.nodeSelector.${set.key}"
      value = set.value
    }
  }


  set {
    name  = "distributor.autoscaling.enabled"
    value = true
  }  

  set {
    name  = "distributor.autoscaling.minReplicas"
    value = var.loki_distributor_min_replicas
  }  

  set {
    name  = "distributor.autoscaling.maxReplicas"
    value = var.loki_distributor_max_replicas
  } 


  dynamic "set" {
    for_each = var.loki_distributor_requests_cpu != null ? ["do it"] : []
    content {
      name  = "distributor.resources.requests.cpu"
      value = var.loki_distributor_requests_cpu
    }
  }

  dynamic "set" {
    for_each = var.loki_distributor_requests_memory != null ? ["do it"] : []
    content {
      name  = "distributor.resources.requests.memory"
      value = var.loki_distributor_requests_memory
    }
  }

  dynamic "set" {
    for_each = var.loki_distributor_limits_cpu != null ? ["do it"] : []
    content {
      name  = "distributor.resources.limits.cpu"
      value = var.loki_distributor_limits_cpu
    }
  }

  dynamic "set" {
    for_each = var.loki_distributor_limits_memory != null ? ["do it"] : []
    content {
      name  = "distributor.resources.limits.memory"
      value = var.loki_distributor_limits_memory
    }
  }

  # loki - querier

  dynamic "set" {
    for_each = var.loki_querier_node_selector != null ? var.loki_querier_node_selector : {}
    content {
      name  = "querier.nodeSelector.${set.key}"
      value = set.value
    }
  }

  set {
    name  = "querier.autoscaling.enabled"
    value = true
  }  

  set {
    name  = "querier.autoscaling.minReplicas"
    value = var.loki_querier_min_replicas
  }  

  set {
    name  = "querier.autoscaling.maxReplicas"
    value = var.loki_querier_max_replicas
  }

  dynamic "set" {
    for_each = var.loki_querier_requests_cpu != null ? ["do it"] : []
    content {
      name  = "querier.resources.requests.cpu"
      value = var.loki_querier_requests_cpu
    }
  }

  dynamic "set" {
    for_each = var.loki_querier_requests_memory != null ? ["do it"] : []
    content {
      name  = "querier.resources.requests.memory"
      value = var.loki_querier_requests_memory
    }
  }

  dynamic "set" {
    for_each = var.loki_querier_limits_cpu != null ? ["do it"] : []
    content {
      name  = "querier.resources.limits.cpu"
      value = var.loki_querier_limits_cpu
    }
  }

  dynamic "set" {
    for_each = var.loki_querier_limits_memory != null ? ["do it"] : []
    content {
      name  = "querier.resources.limits.memory"
      value = var.loki_querier_limits_memory
    }
  }

  # loki - query-frontend

  dynamic "set" {
    for_each = var.loki_query_frontend_node_selector != null ? var.loki_query_frontend_node_selector : {}
    content {
      name  = "queryFrontend.nodeSelector.${set.key}"
      value = set.value
    }
  }

  set {
    name  = "queryFrontend.autoscaling.enabled"
    value = true
  }  

  set {
    name  = "queryFrontend.autoscaling.minReplicas"
    value = var.loki_query_frontend_min_replicas
  }  

  set {
    name  = "queryFrontend.autoscaling.maxReplicas"
    value = var.loki_query_frontend_max_replicas
  }  

  dynamic "set" {
    for_each = var.loki_query_frontend_requests_cpu != null ? ["do it"] : []
    content {
      name  = "queryFrontend.resources.requests.cpu"
      value = var.loki_query_frontend_requests_cpu
    }
  }

  dynamic "set" {
    for_each = var.loki_query_frontend_requests_memory != null ? ["do it"] : []
    content {
      name  = "queryFrontend.resources.requests.memory"
      value = var.loki_query_frontend_requests_memory
    }
  }

  dynamic "set" {
    for_each = var.loki_query_frontend_limits_cpu != null ? ["do it"] : []
    content {
      name  = "queryFrontend.resources.limits.cpu"
      value = var.loki_query_frontend_limits_cpu
    }
  }

  dynamic "set" {
    for_each = var.loki_query_frontend_limits_memory != null ? ["do it"] : []
    content {
      name  = "queryFrontend.resources.limits.memory"
      value = var.loki_query_frontend_limits_memory
    }
  }

  # loki - compactor

  set {
    name  = "compactor.enabled"
    value = var.loki_compactor_enabled
  }

  dynamic "set" {
    for_each = var.loki_compactor_node_selector != null ? var.loki_compactor_node_selector : {}
    content {
      name  = "compactor.nodeSelector.${set.key}"
      value = set.value
    }
  }

  dynamic "set" {
    for_each = var.loki_compactor_requests_cpu != null ? ["do it"] : []
    content {
      name  = "compactor.resources.requests.cpu"
      value = var.loki_compactor_requests_cpu
    }
  }

  dynamic "set" {
    for_each = var.loki_compactor_requests_memory != null ? ["do it"] : []
    content {
      name  = "compactor.resources.requests.memory"
      value = var.loki_compactor_requests_memory
    }
  }

  dynamic "set" {
    for_each = var.loki_compactor_limits_cpu != null ? ["do it"] : []
    content {
      name  = "compactor.resources.limits.cpu"
      value = var.loki_compactor_limits_cpu
    }
  }

  dynamic "set" {
    for_each = var.loki_compactor_limits_memory != null ? ["do it"] : []
    content {
      name  = "compactor.resources.limits.memory"
      value = var.loki_compactor_limits_memory
    }
  }

  # loki - index-gateway

  set {
    name  = "indexGateway.enabled"
    value = var.loki_index_gateway_enabled
  }  

  dynamic "set" {
    for_each = var.loki_index_gateway_node_selector != null ? var.loki_index_gateway_node_selector : {}
    content {
      name  = "indexGateway.nodeSelector.${set.key}"
      value = set.value
    }
  }

  set {
    name  = "indexGateway.replicas"
    value = var.loki_index_gateway_replicas
  }

  set {
    name  = "indexGateway.persistence.enabled"
    value = true
  }

  set {
    name  = "indexGateway.persistence.storageClass"
    value = var.loki_index_gateway_storage_class
  }

  set {
    name  = "indexGateway.persistence.size"
    value = var.loki_index_gateway_storage_size
  }


  dynamic "set" {
    for_each = var.loki_index_gateway_requests_cpu != null ? ["do it"] : []
    content {
      name  = "indexGateway.resources.requests.cpu"
      value = var.loki_index_gateway_requests_cpu
    }
  }

  dynamic "set" {
    for_each = var.loki_index_gateway_requests_memory != null ? ["do it"] : []
    content {
      name  = "indexGateway.resources.requests.memory"
      value = var.loki_index_gateway_requests_memory
    }
  }

  dynamic "set" {
    for_each = var.loki_index_gateway_limits_cpu != null ? ["do it"] : []
    content {
      name  = "indexGateway.resources.limits.cpu"
      value = var.loki_index_gateway_limits_cpu
    }
  }

  dynamic "set" {
    for_each = var.loki_index_gateway_limits_memory != null ? ["do it"] : []
    content {
      name  = "indexGateway.resources.limits.memory"
      value = var.loki_index_gateway_limits_memory
    }
  }

  # loki - gateway

  set {
    name  = "gateway.enabled"
    value = var.loki_gateway_enabled
  }  

  dynamic "set" {
    for_each = var.loki_gateway_node_selector != null ? var.loki_gateway_node_selector : {}
    content {
      name  = "gateway.nodeSelector.${set.key}"
      value = set.value
    }
  }

  set {
    name  = "gateway.autoscaling.enabled"
    value = true
  }  

  set {
    name  = "gateway.autoscaling.minReplicas"
    value = var.loki_gateway_min_replicas
  }  

  set {
    name  = "gateway.autoscaling.maxReplicas"
    value = var.loki_gateway_max_replicas
  }  

  dynamic "set" {
    for_each = var.loki_gateway_requests_cpu != null ? ["do it"] : []
    content {
      name  = "gateway.resources.requests.cpu"
      value = var.loki_gateway_requests_cpu
    }
  }

  dynamic "set" {
    for_each = var.loki_gateway_requests_memory != null ? ["do it"] : []
    content {
      name  = "gateway.resources.requests.memory"
      value = var.loki_gateway_requests_memory
    }
  }

  dynamic "set" {
    for_each = var.loki_gateway_limits_cpu != null ? ["do it"] : []
    content {
      name  = "gateway.resources.limits.cpu"
      value = var.loki_gateway_limits_cpu
    }
  }

  dynamic "set" {
    for_each = var.loki_gateway_limits_memory != null ? ["do it"] : []
    content {
      name  = "gateway.resources.limits.memory"
      value = var.loki_gateway_limits_memory
    }
  }

  set {
    name  = "gateway.ingress.enabled"
    value = var.loki_gateway_ingress_enabled
  }  

  set {
    name  = "gateway.ingress.hosts[0].host"
    value = var.loki_gateway_ingress_host
  }

  set {
    name  = "gateway.ingress.ingressClassName"
    value = var.loki_gateway_ingress_class_name
  }

  set {
    name  = "gateway.ingress.hosts[0].paths[0].path"
    value = var.loki_gateway_ingress_path
  }

  set {
    name  = "gateway.ingress.hosts[0].paths[0].pathType"
    value = var.loki_gateway_ingress_path_type
  }

}

# ================== fluent-bit ================== #

resource "helm_release" "fluent_bit" {
  count             = var.helm_fluent_bit_enabled ? 1 : 0
  name              = "fluent-bit"
  namespace         = "monitoring"
  create_namespace  = true
  repository        = "https://fluent.github.io/helm-charts"
  chart             = "fluent-bit"
  version           = "0.19.24"
  dependency_update = true

  values            = [
    file("${path.module}/helm-values/fluent-bit.yaml")
  ]

  set {
    name = "nodeSelector.eks\\.amazonaws\\.com/compute-type"
    value = "ec2"
  }

}

# ================== tempo-distributed ================== #

resource "helm_release" "tempo_distributed" {
  count             = var.helm_tempo_enabled ? 1 : 0
  name              = "tempo-distributed"
  namespace         = "monitoring"
  create_namespace  = true
  repository        = "https://grafana.github.io/helm-charts"
  chart             = "tempo-distributed"
  version           = "0.17.1"
  dependency_update = true
  timeout           = 600

  values            = [
    file("${path.module}/helm-values/tempo-distributed.yaml")
  ]

  set {
    name  = "storage.trace.s3.bucket"
    value = var.tempo_storage_s3_bucket
  }  

  set {
    name  = "storage.trace.s3.region"
    value = var.tempo_s3_bucket_region
  }  

  set {
    name  = "storage.trace.s3.endpoint"
    value = "s3.dualstack.${var.tempo_s3_bucket_region}.amazonaws.com"
  }  


  # tempo - gateway

  set {
    name  = "gateway.enabled"
    value = var.tempo_gateway_enabled
  }  

  set {
    name  = "gateway.ingress.enabled"
    value = var.tempo_gateway_ingress_enabled
  }  

  set {
    name  = "gateway.ingress.hosts[0].host"
    value = var.tempo_gateway_ingress_host
  }

  set {
    name  = "gateway.ingress.hosts[0].paths[0].path"
    value = var.tempo_gateway_ingress_path
  }

  set {
    name  = "gateway.ingress.hosts[0].paths[0].pathType"
    value = var.tempo_ingress_path_type
  }

  set {
    name  = "gateway.ingress.ingressClassName"
    value = var.tempo_ingress_class_name
  }

  dynamic "set" {
    for_each = var.tempo_gateway_requests_cpu != null ? ["do it"] : []
    content {
      name  = "gateway.resources.requests.cpu"
      value = var.tempo_gateway_requests_cpu
    }
  }

  dynamic "set" {
    for_each = var.tempo_gateway_requests_memory != null ? ["do it"] : []
    content {
      name  = "gateway.resources.requests.memory"
      value = var.tempo_gateway_requests_memory
    }
  }

  dynamic "set" {
    for_each = var.tempo_gateway_limits_cpu != null ? ["do it"] : []
    content {
      name  = "gateway.resources.limits.cpu"
      value = var.tempo_gateway_limits_cpu
    }
  }

  dynamic "set" {
    for_each = var.tempo_gateway_limits_memory != null ? ["do it"] : []
    content {
      name  = "gateway.resources.limits.memory"
      value = var.tempo_gateway_limits_memory
    }
  }

  # tempo - compactor

  dynamic "set" {
    for_each = var.tempo_compactor_requests_cpu != null ? ["do it"] : []
    content {
      name  = "compactor.resources.requests.cpu"
      value = var.tempo_compactor_requests_cpu
    }
  }

  dynamic "set" {
    for_each = var.tempo_compactor_requests_memory != null ? ["do it"] : []
    content {
      name  = "compactor.resources.requests.memory"
      value = var.tempo_compactor_requests_memory
    }
  }

  dynamic "set" {
    for_each = var.tempo_compactor_limits_cpu != null ? ["do it"] : []
    content {
      name  = "compactor.resources.limits.cpu"
      value = var.tempo_compactor_limits_cpu
    }
  }

  dynamic "set" {
    for_each = var.tempo_compactor_limits_memory != null ? ["do it"] : []
    content {
      name  = "compactor.resources.limits.memory"
      value = var.tempo_compactor_limits_memory
    }
  }  

  # tempo - distributor

  dynamic "set" {
    for_each = var.tempo_distributor_requests_cpu != null ? ["do it"] : []
    content {
      name  = "distributor.resources.requests.cpu"
      value = var.tempo_distributor_requests_cpu
    }
  }

  dynamic "set" {
    for_each = var.tempo_distributor_requests_memory != null ? ["do it"] : []
    content {
      name  = "distributor.resources.requests.memory"
      value = var.tempo_distributor_requests_memory
    }
  }

  dynamic "set" {
    for_each = var.tempo_distributor_limits_cpu != null ? ["do it"] : []
    content {
      name  = "distributor.resources.limits.cpu"
      value = var.tempo_distributor_limits_cpu
    }
  }

  dynamic "set" {
    for_each = var.tempo_distributor_limits_memory != null ? ["do it"] : []
    content {
      name  = "distributor.resources.limits.memory"
      value = var.tempo_distributor_limits_memory
    }
  }

  # tempo - ingester

  dynamic "set" {
    for_each = var.tempo_ingester_requests_cpu != null ? ["do it"] : []
    content {
      name  = "ingester.resources.requests.cpu"
      value = var.tempo_ingester_requests_cpu
    }
  }

  dynamic "set" {
    for_each = var.tempo_ingester_requests_memory != null ? ["do it"] : []
    content {
      name  = "ingester.resources.requests.memory"
      value = var.tempo_ingester_requests_memory
    }
  }

  dynamic "set" {
    for_each = var.tempo_ingester_limits_cpu != null ? ["do it"] : []
    content {
      name  = "ingester.resources.limits.cpu"
      value = var.tempo_ingester_limits_cpu
    }
  }

  dynamic "set" {
    for_each = var.tempo_ingester_limits_memory != null ? ["do it"] : []
    content {
      name  = "ingester.resources.limits.memory"
      value = var.tempo_ingester_limits_memory
    }
  }  

  # tempo - querier

  dynamic "set" {
    for_each = var.tempo_querier_requests_cpu != null ? ["do it"] : []
    content {
      name  = "querier.resources.requests.cpu"
      value = var.tempo_querier_requests_cpu
    }
  }

  dynamic "set" {
    for_each = var.tempo_querier_requests_memory != null ? ["do it"] : []
    content {
      name  = "querier.resources.requests.memory"
      value = var.tempo_querier_requests_memory
    }
  }

  dynamic "set" {
    for_each = var.tempo_querier_limits_cpu != null ? ["do it"] : []
    content {
      name  = "querier.resources.limits.cpu"
      value = var.tempo_querier_limits_cpu
    }
  }

  dynamic "set" {
    for_each = var.tempo_querier_limits_memory != null ? ["do it"] : []
    content {
      name  = "querier.resources.limits.memory"
      value = var.tempo_querier_limits_memory
    }
  }  

  # tempo - query-frontend

  dynamic "set" {
    for_each = var.tempo_query_frontend_requests_cpu != null ? ["do it"] : []
    content {
      name  = "queryFrontend.resources.requests.cpu"
      value = var.tempo_query_frontend_requests_cpu
    }
  }

  dynamic "set" {
    for_each = var.tempo_query_frontend_requests_memory != null ? ["do it"] : []
    content {
      name  = "queryFrontend.resources.requests.memory"
      value = var.tempo_query_frontend_requests_memory
    }
  }

  dynamic "set" {
    for_each = var.tempo_query_frontend_limits_cpu != null ? ["do it"] : []
    content {
      name  = "queryFrontend.resources.limits.cpu"
      value = var.tempo_query_frontend_limits_cpu
    }
  }

  dynamic "set" {
    for_each = var.tempo_query_frontend_limits_memory != null ? ["do it"] : []
    content {
      name  = "queryFrontend.resources.limits.memory"
      value = var.tempo_query_frontend_limits_memory
    }
  }  

}
