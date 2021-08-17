locals {

  grafana_datasources_p1 = <<-EOF
grafana:
  datasources:
    datasources.yaml:
      apiVersion: 1
      datasources: 
EOF

  grafana_datasources_p2 = tolist(
    [ for datasource in var.grafana_datasources : 
      {
        name = datasource.name,
        type = lower(datasource.type),
        access = "proxy",
        url  = datasource.url
      }
    ]
  )

}

resource "local_file" "grafana_values" {
    content  = join("\n        ", [local.grafana_datasources_p1, indent(8, yamlencode(local.grafana_datasources_p2))])
    filename = "${path.module}/helm-values/grafana-values.yaml"
}


resource "helm_release" "ingress_nginx" {
  count             = var.helm_ingress_ngnix_enabled ? 1 : 0
  name              = "ingress-nginx"
  namespace         = "ingress-nginx"
  create_namespace  = true
  repository        = "https://kubernetes.github.io/ingress-nginx"
  chart             = "ingress-nginx"
  version           = "3.34.0"

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


  depends_on = [time_sleep.wait_20_seconds]

}

resource "helm_release" "cluster_autoscaler" {
  count      = var.helm_cluster_autoscaler_enabled ? 1 : 0
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.9.2"

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
  version    = "5.8.11"

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


resource "helm_release" "loki_stack" {
  count             = var.helm_loki_stack_enabled ? 1 : 0
  name              = "loki-stack"
  namespace         = "monitoring"
  create_namespace  = true
  repository        = "https://grafana.github.io/helm-charts"
  chart             = "loki-stack"
  version           = "2.4.1"
  dependency_update = true

  values            = [
#    file("${path.module}/helm-values/loki-stack.yaml"),
    local_file.grafana_values.content
  ]

# promtail
  set {
    name  = "promtail.enabled"
    value = var.promtail_enabled
  }

# fluent-bit
  set {
    name  = "fluent-bit.enabled"
    value = var.fluent_bit_enabled
  }

# ========================= loki ========================= #
#loki
  set {
    name  = "loki.enabled"
    value = var.loki_enabled
  }

# loki - persistence
  set {
    name  = "loki.persistence.enabled"
    value = var.loki_persistence_enabled
  }

  set {
    name  = "loki.persistence.storageClassName"
    value = var.loki_persistence_storage_class_name
  }

  set {
    name  = "loki.persistence.size"
    value = var.loki_persistence_size
  }

# loki - ingress
  set {
    name  = "loki.ingress.enabled"
    value = var.loki_ingress_enabled
  }

  set {
    name  = "loki.ingress.hosts[0].host"
    value = var.loki_ingress_host
  }

  set {
    name  = "loki.ingress.hosts[0].paths[0]"
    value = var.loki_ingress_path
  }


# ========================= grafana  ========================= #
  set {
    name  = "grafana.enabled"
    value = var.grafana_enabled
  }

  set {
    name  = "grafana.image.tag"
    value = "8.0.3"
  }


  dynamic "set" {
    for_each = var.grafana_ingress_enabled ? ["do it"] : []
    content {
      name  = "grafana.grafana.ini.server.domain"
      value = var.grafana_ingress_host
    }
  }

  dynamic "set" {
    for_each = var.grafana_ingress_enabled ? ["do it"] : []
    content {
      name  = "grafana.grafana.ini.server.root_url"
      value = "https://${var.grafana_ingress_host}"
    }
  }

# grafana - persistence
  set {
    name  = "grafana.persistence.enabled"
    value = var.grafana_persistence_enabled
  }

  set {
    name  = "grafana.persistence.storageClassName"
    value = var.grafana_persistence_storage_class_name
  }

  set {
    name  = "grafana.persistence.size"
    value = var.grafana_persistence_size
  }

# grafana - ingress
  set {
    name  = "grafana.ingress.enabled"
    value = var.grafana_ingress_enabled
  }

  set {
    name  = "grafana.ingress.hosts[0]"
    value = var.grafana_ingress_host
  }

# grafana - sidecard
  set {
    name  = "grafana.sidecard.datasources.enabled"
    value = var.grafana_sidecard_enabled
  }

# ========================= prometheus ========================= #
  set {
    name  = "prometheus.enabled"
    value = var.prometheus_enabled
  }

# prometheus - alertmanager persistence
  set {
    name  = "prometheus.alertmanager.persistentVolume.enabled"
    value = var.prometheus_alertmanager_persistence_enabled
  }

  set {
    name  = "prometheus.alertmanager.persistentVolume.storageClassName"
    value = var.prometheus_alertmanager_persistence_storage_class_name
  }

  set {
    name  = "prometheus.alertmanager.persistentVolume.size"
    value = var.prometheus_alertmanager_persistence_size
  }


# prometheus - server
  set {
    name  = "prometheus.server.kubeStateMetrics.enabled"
    value = true
  }


  set {
    name  = "prometheus.server.persistentVolume.enabled"
    value = var.prometheus_server_persistence_enabled
  }

  set {
    name  = "prometheus.server.persistentVolume.storageClassName"
    value = var.prometheus_server_persistence_storage_class_name
  }

  set {
    name  = "prometheus.server.persistentVolume.size"
    value = var.prometheus_server_persistence_size
  }

# prometheus - ingress
  set {
    name  = "prometheus.server.ingress.enabled"
    value = var.prometheus_ingress_enabled
  }

  set {
    name  = "prometheus.server.ingress.hosts[0]"
    value = var.prometheus_ingress_host
  }

  depends_on = [time_sleep.wait_20_seconds]

}
