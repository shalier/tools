#!/bin/bash
#dynamic-cilium cni-azure dynamic-azure overlay-cilium overlay-azure kubenet-azure
# overlay-cilium istiod needs to be updated to 1
clusterNames=(dynamic-cilium dynamic-azure overlay-azure overlay-cilium3 kubenet-azure cni-azure)

for clusterName in "${clusterNames[@]}"
do
    kubectl config use-context $clusterName
    kubectl apply -f ../istio-install/base/templates/prometheus.yaml -n aks-istio-system

    echo "Running benchmark on cluster ${clusterName}"
    export CLUSTER_LABEL="${clusterName}"
    ./run_benchmark_job.sh
done