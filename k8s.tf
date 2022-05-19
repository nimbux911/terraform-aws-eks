# These manifests have been taken from https://github.com/open-telemetry/opentelemetry-operator/releases/latest/download/opentelemetry-operator.yaml

resource "kubernetes_manifest" "otel-cert-operator-serving" {
    count             = var.k8s_opentelemetry_enabled ? 1 : 0
    manifest = yamldecode(file("${path.module}/k8s-manifests/otel-cert-operator-serving.yaml"))
    depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-clusterrolebinding-operator-manager" {
    count             = var.k8s_opentelemetry_enabled ? 1 : 0
    manifest = yamldecode(file("${path.module}/k8s-manifests/otel-clusterrolebinding-operator-manager.yaml"))
    depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-clusterrolebinding-operator-proxy" {
    count             = var.k8s_opentelemetry_enabled ? 1 : 0
    manifest = yamldecode(file("${path.module}/k8s-manifests/otel-clusterrolebinding-operator-proxy.yaml"))
    depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-clusterrole-operator-manager" {
  count             = var.k8s_opentelemetry_enabled ? 1 : 0
  manifest = yamldecode(file("${path.module}/k8s-manifests/otel-clusterrole-operator-manager.yaml"))

    depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-clusterrole-operator-metrics-reader" {
    count             = var.k8s_opentelemetry_enabled ? 1 : 0
    manifest = yamldecode(file("${path.module}/k8s-manifests/otel-clusterrole-operator-metrics-reader.yaml"))
    depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-clusterrole-operator-proxy" {
    count             = var.k8s_opentelemetry_enabled ? 1 : 0
    manifest = yamldecode(file("${path.module}/k8s-manifests/otel-clusterrole-operator-proxy.yaml"))
    depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-crd-collectors" {
    count             = var.k8s_opentelemetry_enabled ? 1 : 0
    manifest = yamldecode(file("${path.module}/k8s-manifests/otel-crd-collectors.yaml"))
    depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-crd-instrumentations" {
  count             = var.k8s_opentelemetry_enabled ? 1 : 0
  manifest = yamldecode(file("${path.module}/k8s-manifests/otel-crd-instrumentations.yaml"))
   
    depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-deployment-operator-controller-manager" {
    count             = var.k8s_opentelemetry_enabled ? 1 : 0
    manifest = yamldecode(file("${path.module}/k8s-manifests/otel-deployment-operator-controller-manager.yaml"))
    depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-issuer-operator-selfsigned" {
    count             = var.k8s_opentelemetry_enabled ? 1 : 0
    manifest = yamldecode(file("${path.module}/k8s-manifests/otel-issuer-operator-selfsigned.yaml"))
    depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-ns-operator-system" { 
    count             = var.k8s_opentelemetry_enabled ? 1 : 0
    manifest = yamldecode(file("${path.module}/k8s-manifests/otel-ns-operator-system.yaml"))
    depends_on = [helm_release.cert_manager]
}

resource "kubernetes_manifest" "otel-rolebinding-operator-leader-election" {
    count             = var.k8s_opentelemetry_enabled ? 1 : 0
    manifest = yamldecode(file("${path.module}/k8s-manifests/otel-rolebinding-operator-leader-election.yaml"))
    depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-role-operator-system" {
    count             = var.k8s_opentelemetry_enabled ? 1 : 0
    manifest = yamldecode(file("${path.module}/k8s-manifests/otel-role-operator-system.yaml"))
    depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-sa-operator-controller-manager" {
    count             = var.k8s_opentelemetry_enabled ? 1 : 0
    manifest = yamldecode(file("${path.module}/k8s-manifests/otel-sa-operator-controller-manager.yaml"))
    depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-svc-operator-controller-manager" {
    count             = var.k8s_opentelemetry_enabled ? 1 : 0
    manifest = yamldecode(file("${path.module}/k8s-manifests/otel-svc-operator-controller-manager.yaml"))
    depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-svc-operator-webhook" {
    count             = var.k8s_opentelemetry_enabled ? 1 : 0
    manifest = yamldecode(file("${path.module}/k8s-manifests/otel-svc-operator-webhook.yaml"))
    depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-webhookconfig" {
    count             = var.k8s_opentelemetry_enabled ? 1 : 0
    manifest = yamldecode(file("${path.module}/k8s-manifests/otel-webhookconfig.yaml"))
    depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}

resource "kubernetes_manifest" "otel-webhookvalidation" {
    count             = var.k8s_opentelemetry_enabled ? 1 : 0
    manifest = yamldecode(file("${path.module}/k8s-manifests/otel-webhookvalidation.yaml"))
    depends_on = [helm_release.cert_manager, kubernetes_manifest.otel-ns-operator-system]
}
