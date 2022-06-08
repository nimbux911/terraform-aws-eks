# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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


