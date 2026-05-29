apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: ${name}
  namespace: ${namespace}
  labels:
    release: prometheus-stack
spec:
  namespaceSelector:
    matchNames:
      - ${namespace}
  selector:
    matchLabels:
      app.kubernetes.io/name: envoy-metrics
      envoy-metrics: ${metrics_scope}
  endpoints:
    - interval: 30s
      path: /stats/prometheus
      port: metrics
      metricRelabelings:
        - action: keep
          sourceLabels:
            - __name__
          regex: envoy_http_downstream_rq_total|envoy_http_downstream_rq_xx|envoy_http_downstream_rq_time_bucket|envoy_http_downstream_rq_time_sum|envoy_http_downstream_rq_time_count|envoy_cluster_upstream_rq_total|envoy_cluster_upstream_rq_xx|envoy_cluster_upstream_rq_time_bucket|envoy_cluster_upstream_rq_time_sum|envoy_cluster_upstream_rq_time_count
        - action: replace
          sourceLabels:
            - envoy_cluster_name
          regex: httproute/([^/]+)/([^/]+)/.*
          targetLabel: exported_namespace
          replacement: $1
        - action: replace
          sourceLabels:
            - envoy_cluster_name
          regex: httproute/([^/]+)/([^/]+)/.*
          targetLabel: exported_service
          replacement: $2
