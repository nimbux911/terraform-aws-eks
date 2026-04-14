# These manifests have been taken from https://github.com/open-telemetry/opentelemetry-operator/releases/latest/download/opentelemetry-operator.yaml

resource "kubernetes_manifest" "otel-cert-operator-serving" {
  count      = var.k8s_opentelemetry_enabled ? 1 : 0
  manifest   = yamldecode(file("${path.module}/k8s-manifests/otel-cert-operator-serving.yaml"))
  depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-clusterrolebinding-operator-manager" {
  count      = var.k8s_opentelemetry_enabled ? 1 : 0
  manifest   = yamldecode(file("${path.module}/k8s-manifests/otel-clusterrolebinding-operator-manager.yaml"))
  depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-clusterrolebinding-operator-proxy" {
  count      = var.k8s_opentelemetry_enabled ? 1 : 0
  manifest   = yamldecode(file("${path.module}/k8s-manifests/otel-clusterrolebinding-operator-proxy.yaml"))
  depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-clusterrole-operator-manager" {
  count    = var.k8s_opentelemetry_enabled ? 1 : 0
  manifest = yamldecode(file("${path.module}/k8s-manifests/otel-clusterrole-operator-manager.yaml"))

  depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-clusterrole-operator-metrics-reader" {
  count      = var.k8s_opentelemetry_enabled ? 1 : 0
  manifest   = yamldecode(file("${path.module}/k8s-manifests/otel-clusterrole-operator-metrics-reader.yaml"))
  depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-clusterrole-operator-proxy" {
  count      = var.k8s_opentelemetry_enabled ? 1 : 0
  manifest   = yamldecode(file("${path.module}/k8s-manifests/otel-clusterrole-operator-proxy.yaml"))
  depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-crd-collectors" {
  count      = var.k8s_opentelemetry_enabled ? 1 : 0
  manifest   = yamldecode(file("${path.module}/k8s-manifests/otel-crd-collectors.yaml"))
  depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-crd-instrumentations" {
  count    = var.k8s_opentelemetry_enabled ? 1 : 0
  manifest = yamldecode(file("${path.module}/k8s-manifests/otel-crd-instrumentations.yaml"))

  depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-deployment-operator-controller-manager" {
  count      = var.k8s_opentelemetry_enabled ? 1 : 0
  manifest   = yamldecode(file("${path.module}/k8s-manifests/otel-deployment-operator-controller-manager.yaml"))
  depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-issuer-operator-selfsigned" {
  count      = var.k8s_opentelemetry_enabled ? 1 : 0
  manifest   = yamldecode(file("${path.module}/k8s-manifests/otel-issuer-operator-selfsigned.yaml"))
  depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-ns-operator-system" {
  count      = var.k8s_opentelemetry_enabled ? 1 : 0
  manifest   = yamldecode(file("${path.module}/k8s-manifests/otel-ns-operator-system.yaml"))
  depends_on = [helm_release.cert_manager]
}

resource "kubernetes_manifest" "otel-rolebinding-operator-leader-election" {
  count      = var.k8s_opentelemetry_enabled ? 1 : 0
  manifest   = yamldecode(file("${path.module}/k8s-manifests/otel-rolebinding-operator-leader-election.yaml"))
  depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-role-operator-system" {
  count      = var.k8s_opentelemetry_enabled ? 1 : 0
  manifest   = yamldecode(file("${path.module}/k8s-manifests/otel-role-operator-system.yaml"))
  depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-sa-operator-controller-manager" {
  count      = var.k8s_opentelemetry_enabled ? 1 : 0
  manifest   = yamldecode(file("${path.module}/k8s-manifests/otel-sa-operator-controller-manager.yaml"))
  depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-svc-operator-controller-manager" {
  count      = var.k8s_opentelemetry_enabled ? 1 : 0
  manifest   = yamldecode(file("${path.module}/k8s-manifests/otel-svc-operator-controller-manager.yaml"))
  depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-svc-operator-webhook" {
  count      = var.k8s_opentelemetry_enabled ? 1 : 0
  manifest   = yamldecode(file("${path.module}/k8s-manifests/otel-svc-operator-webhook.yaml"))
  depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-webhookconfig" {
  count      = var.k8s_opentelemetry_enabled ? 1 : 0
  manifest   = yamldecode(file("${path.module}/k8s-manifests/otel-webhookconfig.yaml"))
  depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-webhookvalidation" {
  count      = var.k8s_opentelemetry_enabled ? 1 : 0
  manifest   = yamldecode(file("${path.module}/k8s-manifests/otel-webhookvalidation.yaml"))
  depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "envoy_gateway_proxy_config" {
  count = var.k8s_envoy_gateway_enabled ? 1 : 0

  manifest = yamldecode(templatefile("${path.module}/k8s-manifests/envoy-gateway-proxy-config.yaml.tpl", {
    name                    = var.envoy_gateway_name
    namespace               = var.envoy_gateway_namespace
    service_type            = var.envoy_gateway_service_type
    external_traffic_policy = var.envoy_gateway_external_traffic_policy
    nodeport_enabled        = var.envoy_gateway_service_type == "NodePort"
    http_nodeport           = var.envoy_gateway_http_nodeport
  }))

  depends_on = [helm_release.envoy_gateway]
}

resource "kubernetes_manifest" "envoy_gatewayclass" {
  count = var.k8s_envoy_gateway_enabled ? 1 : 0

  manifest = yamldecode(templatefile("${path.module}/k8s-manifests/envoy-gatewayclass.yaml.tpl", {
    gatewayclass_name = var.envoy_gatewayclass_name
    proxy_name        = var.envoy_gateway_name
    namespace         = var.envoy_gateway_namespace
  }))

  depends_on = [helm_release.envoy_gateway]
}

resource "kubernetes_manifest" "envoy_gateway" {
  count = var.k8s_envoy_gateway_enabled ? 1 : 0

  manifest = yamldecode(templatefile("${path.module}/k8s-manifests/envoy-gateway.yaml.tpl", {
    gateway_name      = var.envoy_gateway_name
    namespace         = var.envoy_gateway_namespace
    gatewayclass_name = var.envoy_gatewayclass_name
  }))

  depends_on = [
    helm_release.envoy_gateway,
    kubernetes_manifest.envoy_gateway_proxy_config,
    kubernetes_manifest.envoy_gatewayclass,
  ]
}

resource "kubernetes_manifest" "envoy_internal_gatewayclass" {
  count = var.k8s_envoy_internal_gateway_enabled ? 1 : 0

  manifest = yamldecode(templatefile("${path.module}/k8s-manifests/envoy-gatewayclass.yaml.tpl", {
    gatewayclass_name = var.envoy_internal_gatewayclass_name
    proxy_name        = var.envoy_internal_gateway_name
    namespace         = var.envoy_gateway_namespace
  }))

  depends_on = [
    helm_release.envoy_gateway,
    kubernetes_manifest.envoy_internal_gateway_proxy_config,
  ]
}

resource "kubernetes_manifest" "envoy_internal_gateway_proxy_config" {
  count = var.k8s_envoy_internal_gateway_enabled ? 1 : 0

  manifest = yamldecode(templatefile("${path.module}/k8s-manifests/envoy-gateway-proxy-config.yaml.tpl", {
    name                    = var.envoy_internal_gateway_name
    namespace               = var.envoy_gateway_namespace
    service_type            = var.envoy_internal_gateway_service_type
    external_traffic_policy = var.envoy_internal_gateway_external_traffic_policy
    nodeport_enabled        = var.envoy_internal_gateway_service_type == "NodePort"
    http_nodeport           = var.envoy_internal_gateway_http_nodeport
  }))

  depends_on = [helm_release.envoy_gateway]
}

resource "kubernetes_manifest" "envoy_internal_gateway" {
  count = var.k8s_envoy_internal_gateway_enabled ? 1 : 0

  manifest = yamldecode(templatefile("${path.module}/k8s-manifests/envoy-gateway.yaml.tpl", {
    gateway_name      = var.envoy_internal_gateway_name
    namespace         = var.envoy_gateway_namespace
    gatewayclass_name = var.envoy_internal_gatewayclass_name
  }))

  depends_on = [
    helm_release.envoy_gateway,
    kubernetes_manifest.envoy_internal_gatewayclass,
    kubernetes_manifest.envoy_internal_gateway_proxy_config,
  ]
}

resource "kubernetes_service_v1" "envoy_external_metrics_service" {
  count = var.k8s_envoy_proxy_service_monitor_enabled ? 1 : 0

  metadata {
    name      = "envoy-external-metrics"
    namespace = var.envoy_gateway_namespace
    annotations = {
      "prometheus.io/path"   = "/stats/prometheus"
      "prometheus.io/port"   = "19001"
      "prometheus.io/scrape" = "true"
    }
    labels = {
      "app.kubernetes.io/name" = "envoy-metrics"
      "envoy-metrics"          = "external"
    }
  }

  spec {
    type = "ClusterIP"

    port {
      name        = "metrics"
      port        = 19001
      protocol    = "TCP"
      target_port = "19001"
    }

    selector = {
      "app.kubernetes.io/component"                    = "proxy"
      "app.kubernetes.io/managed-by"                   = "envoy-gateway"
      "app.kubernetes.io/name"                         = "envoy"
      "gateway.envoyproxy.io/owning-gateway-name"      = var.envoy_gateway_name
      "gateway.envoyproxy.io/owning-gateway-namespace" = var.envoy_gateway_namespace
    }
  }

  depends_on = [kubernetes_manifest.envoy_gateway]
}

resource "kubernetes_service_v1" "envoy_internal_metrics_service" {
  count = var.k8s_envoy_proxy_service_monitor_enabled && var.k8s_envoy_internal_gateway_enabled ? 1 : 0

  metadata {
    name      = "envoy-internal-metrics"
    namespace = var.envoy_gateway_namespace
    annotations = {
      "prometheus.io/path"   = "/stats/prometheus"
      "prometheus.io/port"   = "19001"
      "prometheus.io/scrape" = "true"
    }
    labels = {
      "app.kubernetes.io/name" = "envoy-metrics"
      "envoy-metrics"          = "internal"
    }
  }

  spec {
    type = "ClusterIP"

    port {
      name        = "metrics"
      port        = 19001
      protocol    = "TCP"
      target_port = "19001"
    }

    selector = {
      "app.kubernetes.io/component"                    = "proxy"
      "app.kubernetes.io/managed-by"                   = "envoy-gateway"
      "app.kubernetes.io/name"                         = "envoy"
      "gateway.envoyproxy.io/owning-gateway-name"      = var.envoy_internal_gateway_name
      "gateway.envoyproxy.io/owning-gateway-namespace" = var.envoy_gateway_namespace
    }
  }

  depends_on = [kubernetes_manifest.envoy_internal_gateway]
}

resource "kubernetes_manifest" "envoy_external_metrics_service_monitor" {
  count = var.k8s_envoy_proxy_service_monitor_enabled ? 1 : 0

  manifest = yamldecode(templatefile("${path.module}/k8s-manifests/envoy-metrics-servicemonitor.yaml.tpl", {
    name          = "envoy-external-proxy"
    namespace     = var.envoy_gateway_namespace
    metrics_scope = "external"
  }))

  depends_on = [kubernetes_service_v1.envoy_external_metrics_service]
}

resource "kubernetes_manifest" "envoy_internal_metrics_service_monitor" {
  count = var.k8s_envoy_proxy_service_monitor_enabled && var.k8s_envoy_internal_gateway_enabled ? 1 : 0

  manifest = yamldecode(templatefile("${path.module}/k8s-manifests/envoy-metrics-servicemonitor.yaml.tpl", {
    name          = "envoy-internal-proxy"
    namespace     = var.envoy_gateway_namespace
    metrics_scope = "internal"
  }))

  depends_on = [kubernetes_service_v1.envoy_internal_metrics_service]
}
