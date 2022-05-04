resource "kubernetes_manifest" "otel_operator" {
    count             = var.k8s_opentelemetry_enabled ? 1 : 0
    manifest = yamldecode(file("${path.module}/k8s-manifests/opentelemetry-operator.yaml"))
}