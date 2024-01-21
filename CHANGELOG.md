# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [5.1.0] - 2024-01-21

- Enable optional custom configurations for EKS addons.

## [5.0.0] - 2024-01-21

- Add dynamic root volume name depending on the AMI that is being used for the worker nodes.
- Attach worker nodes security groups directly to ENIs.
- Set spot instance type as "one-time".
- Add output for EKS cluster name.
- Add input to set if the worker nodes are public or private.

## [4.7.1] - 2023-07-25

### Added
- Minimum Replica count for ingress-nginx and ingress-additional-nginx

## [4.7.0] - 2023-04-21

### Fixed
- AWS Managed nodegroups are not added to ELB Target groups. [issue 36](https://github.com/nimbux911/terraform-aws-eks/issues/36)
- Cluster autoscaler permissions to describe managed nodegroups. [issue 37.1](https://github.com/nimbux911/terraform-aws-eks/issues/37)

### Added
- OpenID Connect Provider for EKS to enable IRSA.
- IAM assumable role with oidc for EKS ebs-csi-controller.

## [4.6.2] - 2023-04-21

### Fixed

- There was a variable typo. It was pointing to null instead of "".

## [4.6.1] - 2023-03-30

### Fixed

- Update kubernetes registry from k8s.gcr.io Image to registry.k8s.io, based on this [announcement](https://kubernetes.io/blog/2023/02/06/k8s-gcr-io-freeze-announcement/)
- Typo on Tempo Helm chart version variable name.
- Typo on Tempo priority class name set value.

## [4.6.0] - 2023-02-23

### Added

- Add additonal scrape configs for prometheus

### Fixed

- Typo in priority class name in some helm installations and metrics server

## [4.5.0] - 2023-01-20

### Added

- Add priorityclass input to all helm installations

## [4.4.0] - 2023-01-17

### Added

- add version selector for helm charts
- updated default version of the metrics server from 5.11.3 to 6.0.5

## [4.3.1] - 2022-12-07

### Added

- add persistence to the grafana chart

## [4.3.0] - 2022-12-02

### Added
- grafana helm chart

## [4.2.1] - 2022-11-16

### Fixed 
- Typo on additional ingressclass "nginx-additional". Before it was "nginx-private"

## [4.2.0] - 2022-11-10

### Added
- Additional nginx controller instance
- Enable https traffic to nginx 

## [4.1.1] - 2022-11-04

### Added
- Request cpu and memory for ingress-nginx chart

### Fixed 
- Typo on "helm_ingress_nginx_enabled". Before it was "helm_ingress_ngnix_enabled"

## [4.1.0] - 2022-11-01

### Added
- Instance market options to use spot instances on custom node groups.
- Added a new variable under loki called "loki_max_query_length" 

## [4.0.0] - 2022-07-20

### Added
- AWS managed node groups
- multiple custom node groups
- NodeSelector input for loki and prometheus components
- Labels and taints for node groups
- k8s default api version updated to "client.authentication.k8s.io/v1beta1"
- Terraform Launch configuration replaced by Terraform launch template

### Fixed
- [Loki issue #5909](https://github.com/grafana/loki/issues/5909#issuecomment-1120821579) with image v2.5.0-with-pr-6123-a630ae3 

## [3.1.8] - 2022-07-14

### Added
- ASG's tags attribute (deprecated) replaced by tag

## [3.1.7] - 2022-07-06

### Added
- Input to define k8s authentication api for tf providers

### Fixed
- Removed dependency between ingress-nginx serviceMonitor and Prometheus helm chart

## [3.1.6] - 2022-06-28

### Added
- Input for SSH ingress rules to eks workers
- Ingress rule to allow communication between EC2 nodes and AWS managed nodes

## [3.1.5] - 2022-06-27

### Fixed
- terraform required_providers added [Issue #12](https://github.com/nimbux911/terraform-aws-eks/issues/12)

## [3.1.4] - 2022-06-22

### Added
- Add Apache License Version 2.0 (January 2004) https://www.apache.org/licenses/.

## [3.1.3] - 2022-06-08

### Fixed
- Add missing IAM policy for Cluster Autoscaler to EKS Worker Nodes IAM role

## [3.1.2] - 2022-06-03

### Fixed
- ingress-nginx metrics expose to Prometheus

## [3.1.1] - 2022-06-02

### Fixed
- fluent-bit service parsers config
- module source un README. Ssh url replaced for https instead

## [3.1.0] - 2022-05-27

### Added
- EKS addons input.

## [3.0.1] - 2022-05-19

### Fixed
- Prometheus-node-exporter tried to add pods in fargate nodes (fargate doesn't support daemonsets) [Issue #3](https://github.com/nimbux911/terraform-aws-eks/issues/3)
- OTEL manifests failed because namespace didn't exist [Issue #2](https://github.com/nimbux911/terraform-aws-eks/issues/2)
- cert-manager release failed because namespace didn't exist

### Added
- ignore_change option for asg desired_capacity, to be handled by the cluster-autoscaler

## [3.0.0] - 2022-05-06

### Added
- aws-iam-authenticator is not needed anymore
- loki-stack has been replaced for loki-distributed, kube-stack-prometheus and fluent-bit helm charts
- tempo-distributed helm chart
- cert-manager helm chart
- opentelemetry manifests for auto-instrumentation
- ingress-nginx, metrics-server and cluster-autoscaler helm charts updated to latest version

## [2.1.0] - 2021-11-30

### Added

- Add max_pods_per_node kubelet argument.
- README outputs.

## [2.0.5] - 2021-08-17

### Fixed

- Add current aws region to cluster-autoscaler helm chart.
- CHANGELOG and README outputs.

## [2.0.4] - 2021-08-09

### Added

- Eks endpoint and CA to outputs to be used for external helm release provider.
- Updating provider to allow EKS cluster create by Terragrunt role.

## [2.0.3] - 2021-07-05

### Added

- Grafana datasources inputs.

## [2.0.2] - 2021-07-05

### Fixed

- Prometheus server ingress values.

## [2.0.0] - 2021-06-30

### Fixed

- The aws-auth configmap used to fail because the cluster wasn't ready yet.

### Added

- Users and roles can be added to the aws-auth configmap and managed by terraform
- Open ingress port to worker nodes if his Helm chart is enabled
- Bootstrapping: ingress-nginx, cluster-autoscaler, metrics-server and loki-stack helm charts

## [1.0.0] - 2021-05-05

### Added

- First version of the eks module.


