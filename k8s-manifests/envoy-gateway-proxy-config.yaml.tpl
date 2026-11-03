apiVersion: gateway.envoyproxy.io/v1alpha1
kind: EnvoyProxy
metadata:
  name: ${name}
  namespace: ${namespace}
spec:
  provider:
    type: Kubernetes
    kubernetes:
%{ if hpa != null ~}
      envoyHpa:
        minReplicas: ${hpa.min_replicas}
        maxReplicas: ${hpa.max_replicas}
        metrics:
          - type: Resource
            resource:
              name: cpu
              target:
                type: Utilization
                averageUtilization: ${hpa.cpu_utilization_percentage}
%{ endif ~}
%{ if hpa == null || length(container_resources) > 0 ~}
      envoyDeployment:
%{ if hpa == null ~}
        replicas: ${replicas}
%{ endif ~}
%{ if length(container_resources) > 0 ~}
        patch:
          type: StrategicMerge
          value:
            spec:
              template:
                spec:
                  containers: ${jsonencode([for name, resources in container_resources : { name = name, resources = resources }])}
%{ endif ~}
%{ endif ~}
      envoyService:
        type: ${service_type}
        externalTrafficPolicy: ${external_traffic_policy}
%{ if nodeport_enabled ~}
        patch:
          type: StrategicMerge
          value:
            spec:
              ports:
                - port: 80
                  nodePort: ${http_nodeport}
%{ endif ~}
