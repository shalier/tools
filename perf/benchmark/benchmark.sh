#!/bin/bash
#dynamic-cilium cni-azure dynamic-azure overlay-cilium overlay-azure kubenet-azure
clusterNames=(cni-azure dynamic-cilium dynamic-azure overlay-cilium overlay-azure kubenet-azure)

for clusterName in "${clusterNames[@]}"
do
    echo "Running benchmark on cluster ${clusterName}"
    export CLUSTER_LABEL="${clusterName}"
    ./run_benchmark_job.sh
done