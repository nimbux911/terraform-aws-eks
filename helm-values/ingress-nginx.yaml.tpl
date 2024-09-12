controller:
  service:
    type: NodePort
    nodePorts:
      http: 32080
      https: 32443
      tcp:
        8080: 32808

  admissionWebhooks:
    enabled: false

  metrics:
    port: 10254
    service:
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "10254"
    serviceMonitor:
      additionalLabels:
        release: prometheus-stack

  %{ if ingress_log_format_enabled }
  data:
    log-format-upstream: "${ingress_log_format_upstream}"
  %{ endif }

  %{if enableNodeAffinity }
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: ${nodeAffinityLabelKey}
            operator: In
            values:
              - ${nodeAffinityLabelValue}
  %{endif}
