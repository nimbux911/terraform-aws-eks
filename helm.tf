#locals {
#
#  grafana_datasources_p1 = <<-EOF
#grafana:
#  datasources:
#    datasources.yaml:
#      apiVersion: 1
#      datasources: 
#EOF
#
#  grafana_datasources_p2 = tolist(
#    [ for datasource in var.grafana_datasources : 
#      {
#        name = datasource.name,
#        type = lower(datasource.type),
#        access = "proxy",
#        url  = datasource.url
#      }
#    ]
#  )
#
#}
#
#resource "local_file" "grafana_values" {
#    content  = join("\n        ", [local.grafana_datasources_p1, indent(8, yamlencode(local.grafana_datasources_p2))])
#    filename = "${path.module}/helm-values/grafana-values.yaml"
#}

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


  dynamic "set" {
    for_each = var.prometheus_enabled ? ["do it"] : []
    content {
      name  = "controller.metrics.enabled"
      value = true
    }
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
  count      = var.helm_cert_manager_enabled ? 1 : 0
  name       = "cert-manager"
  namespace  = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.6.1"

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

  values            = [
    file("${path.module}/helm-values/kube-prometheus-stack.yaml"),
  ]

  set {
    name  = "prometheus.prometheusSpec.replicas"
    value = var.prometheus_replicas
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

  values            = [
    file("${path.module}/helm-values/loki-distributed.yaml")
  ]

  # loki - storage
  set {
    name  = "loki.storageConfig.aws.s3"
    value = "s3://${var.loki_s3_bucket_region}/${var.loki_storage_s3_bucket}"
  }  

  # loki - ingester

  set {
    name  = "ingester.replicas"
    value = var.loki_ingester_replicas
  }  

  # loki - distributor

  set {
    name  = "distributor.autoscaling.minReplicas"
    value = var.loki_distributor_min_replicas
  }  

  set {
    name  = "distributor.autoscaling.maxReplicas"
    value = var.loki_distributor_max_replicas
  }  

  # loki - querier

  set {
    name  = "querier.autoscaling.minReplicas"
    value = var.loki_querier_min_replicas
  }  

  set {
    name  = "querier.autoscaling.maxReplicas"
    value = var.loki_querier_max_replicas
  }  

  # loki - query-frontend

  set {
    name  = "queryFrontend.autoscaling.minReplicas"
    value = var.loki_query_frontend_min_replicas
  }  

  set {
    name  = "queryFrontend.autoscaling.maxReplicas"
    value = var.loki_query_frontend_max_replicas
  }  

  # loki - compactor

  set {
    name  = "compactor.enabled"
    value = var.loki_compactor_enabled
  }  

  # loki - index-gateway

  set {
    name  = "indexGateway.enabled"
    value = var.loki_index_gateway_enabled
  }  

  set {
    name  = "indexGateway.replicas"
    value = var.loki_index_gateway_replicas
  }

  # loki - gateway

  set {
    name  = "gateway.enabled"
    value = var.loki_gateway_enabled
  }  

  set {
    name  = "gateway.autoscaling.minReplicas"
    value = var.loki_gateway_min_replicas
  }  

  set {
    name  = "gateway.autoscaling.maxReplicas"
    value = var.loki_gateway_max_replicas
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
    name  = "loki.ingress.hosts[0].paths[0].path"
    value = var.loki_gateway_ingress_path
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

  values            = [
    file("${path.module}/helm-values/tempo-distributed.yaml"),
  ]

  # tempo - storage
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

}
