apiVersion: gateway.envoyproxy.io/v1alpha1
kind: EnvoyProxy
metadata:
  name: ${name}
  namespace: ${namespace}
spec:
  provider:
    type: Kubernetes
    kubernetes:
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
