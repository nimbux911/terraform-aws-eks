apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: ${gatewayclass_name}
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
  parametersRef:
    group: gateway.envoyproxy.io
    kind: EnvoyProxy
    name: ${proxy_name}
    namespace: ${namespace}
