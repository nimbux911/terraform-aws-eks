# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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


