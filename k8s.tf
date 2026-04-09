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

  manifest = {
    apiVersion = "gateway.envoyproxy.io/v1alpha1"
    kind       = "EnvoyProxy"
    metadata = {
      name      = var.envoy_gateway_name
      namespace = var.envoy_gateway_namespace
    }
    spec = {
      provider = {
        type = "Kubernetes"
        kubernetes = {
          envoyService = merge(
            {
              type                  = var.envoy_gateway_service_type
              externalTrafficPolicy = var.envoy_gateway_external_traffic_policy
            },
            var.envoy_gateway_service_type == "NodePort" ? {
              patch = {
                type = "StrategicMerge"
                value = {
                  spec = {
                    ports = [
                      {
                        port     = 80
                        nodePort = var.envoy_gateway_http_nodeport
                      },
                    ]
                  }
                }
              }
            } : {}
          )
        }
      }
    }
  }

  depends_on = [helm_release.envoy_gateway]
}

resource "kubernetes_manifest" "envoy_gatewayclass" {
  count = var.k8s_envoy_gateway_enabled ? 1 : 0

  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "GatewayClass"
    metadata = {
      name = var.envoy_gatewayclass_name
    }
    spec = {
      controllerName = "gateway.envoyproxy.io/gatewayclass-controller"
      parametersRef = {
        group     = "gateway.envoyproxy.io"
        kind      = "EnvoyProxy"
        name      = var.envoy_gateway_name
        namespace = var.envoy_gateway_namespace
      }
    }
  }

  depends_on = [helm_release.envoy_gateway]
}

resource "kubernetes_manifest" "envoy_gateway" {
  count = var.k8s_envoy_gateway_enabled ? 1 : 0

  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"
    metadata = {
      name      = var.envoy_gateway_name
      namespace = var.envoy_gateway_namespace
    }
    spec = {
      gatewayClassName = var.envoy_gatewayclass_name
      listeners = [
        {
          name     = "http"
          protocol = "HTTP"
          port     = 80
          allowedRoutes = {
            namespaces = {
              from = "All"
            }
          }
        }
      ]
    }
  }

  depends_on = [
    helm_release.envoy_gateway,
    kubernetes_manifest.envoy_gateway_proxy_config,
    kubernetes_manifest.envoy_gatewayclass,
  ]
}

resource "kubernetes_manifest" "envoy_internal_gatewayclass" {
  count = var.k8s_envoy_internal_gateway_enabled ? 1 : 0

  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "GatewayClass"
    metadata = {
      name = var.envoy_internal_gatewayclass_name
    }
    spec = {
      controllerName = "gateway.envoyproxy.io/gatewayclass-controller"
      parametersRef = {
        group     = "gateway.envoyproxy.io"
        kind      = "EnvoyProxy"
        name      = var.envoy_internal_gateway_name
        namespace = var.envoy_gateway_namespace
      }
    }
  }

  depends_on = [
    helm_release.envoy_gateway,
    kubernetes_manifest.envoy_internal_gateway_proxy_config,
  ]
}

resource "kubernetes_manifest" "envoy_internal_gateway_proxy_config" {
  count = var.k8s_envoy_internal_gateway_enabled ? 1 : 0

  manifest = {
    apiVersion = "gateway.envoyproxy.io/v1alpha1"
    kind       = "EnvoyProxy"
    metadata = {
      name      = var.envoy_internal_gateway_name
      namespace = var.envoy_gateway_namespace
    }
    spec = {
      provider = {
        type = "Kubernetes"
        kubernetes = {
          envoyService = merge(
            {
              type                  = var.envoy_internal_gateway_service_type
              externalTrafficPolicy = var.envoy_internal_gateway_external_traffic_policy
            },
            var.envoy_internal_gateway_service_type == "NodePort" ? {
              patch = {
                type = "StrategicMerge"
                value = {
                  spec = {
                    ports = [
                      {
                        port     = 80
                        nodePort = var.envoy_internal_gateway_http_nodeport
                      },
                    ]
                  }
                }
              }
            } : {}
          )
        }
      }
    }
  }

  depends_on = [helm_release.envoy_gateway]
}

resource "kubernetes_manifest" "envoy_internal_gateway" {
  count = var.k8s_envoy_internal_gateway_enabled ? 1 : 0

  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"
    metadata = {
      name      = var.envoy_internal_gateway_name
      namespace = var.envoy_gateway_namespace
    }
    spec = {
      gatewayClassName = var.envoy_internal_gatewayclass_name
      listeners = [
        {
          name     = "http"
          protocol = "HTTP"
          port     = 80
          allowedRoutes = {
            namespaces = {
              from = "All"
            }
          }
        }
      ]
    }
  }

  depends_on = [
    helm_release.envoy_gateway,
    kubernetes_manifest.envoy_internal_gatewayclass,
    kubernetes_manifest.envoy_internal_gateway_proxy_config,
  ]
}

resource "kubernetes_manifest" "envoy_cosun_backend_route" {
  count = var.k8s_envoy_cosun_backend_route_enabled ? 1 : 0

  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "backend"
      namespace = "cosun"
      labels = {
        app = "backend"
      }
    }
    spec = {
      parentRefs = [
        {
          name      = var.envoy_gateway_name
          namespace = var.envoy_gateway_namespace
        }
      ]
      hostnames = [var.envoy_cosun_backend_hostname]
      rules = [
        {
          matches = [
            {
              path = {
                type  = "PathPrefix"
                value = "/"
              }
            }
          ]
          filters = [
            {
              type = "URLRewrite"
              urlRewrite = {
                path = {
                  type            = "ReplaceFullPath"
                  replaceFullPath = "/"
                }
              }
            }
          ]
          backendRefs = [
            {
              name = "backend"
              port = 80
            }
          ]
        }
      ]
    }
  }

  depends_on = [kubernetes_manifest.envoy_gateway]
}
