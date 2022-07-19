#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint "${cluster_endpoint}" --b64-cluster-ca "${cluster_ca}" "${cluster_name}" ${max_pods_enabled} --kubelet-extra-args "${max_pods_per_node}" --node-labels=${node_labels}


