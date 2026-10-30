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
%{ else ~}
      envoyDeployment:
        replicas: ${replicas}
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
