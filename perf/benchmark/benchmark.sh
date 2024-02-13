#!/bin/bash
export RESOURCE_GROUP="${RESOURCE_GROUP:-xiarg}"

export NODESUBNET="${NODESUBNET:-nodesubnet}"
export PODSUBNET="${PODSUBNET:-podsubnet}"
export DYNAMIC_VNET="${DYNAMIC_VNET:-dynamic-vnet}"
export KUBENET_VNET="${KUBENET_VNET:-myAKSVnet}"
export KUBENET_SUBNET="${KUBENET_SUBNET:-myAKSSubnet}"
export TEST_USER_NODE="${TEST_USER_NODE:-userpool}"
export TEST_PROM_NODE="${TEST_PROM_NODE:-prom}"
export VNET_SUBNET_ID="/subscriptions/${SUBSCRIPTION}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${DYNAMIC_VNET}/subnets/${NODESUBNET}"
export POD_SUBNET_ID="/subscriptions/${SUBSCRIPTION}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${DYNAMIC_VNET}/subnets/${PODSUBNET}"
export KUBENET_VNET_SUBNET_ID="/subscriptions/${SUBSCRIPTION}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${KUBENET_VNET}/subnets/${KUBENET_SUBNET}"

export CNI_AZURE_CLUSTER_NAME="${CNI_AZURE_CLUSTER_NAME:-cni-azure2}"
export DYNAMIC_AZURE_CLUSTER_NAME="${DYNAMIC_AZURE_CLUSTER_NAME:-dynamic-azure2}"
export DYNAMIC_CILIUM_CLUSTER_NAME="${DYNAMIC_CILIUM_CLUSTER_NAME:-dynamic-cilium2}"
export OVERLAY_AZURE_CLUSTER_NAME="${OVERLAY_AZURE_CLUSTER_NAME:-overlay-azure2}"
export OVERLAY_CILIUM_CLUSTER_NAME="${OVERLAY_CILIUM_CLUSTER_NAME:-overlay-cilium2}"
export KUBENET_AZURE_CLUSTER_NAME="${KUBENET_AZURE_CLUSTER_NAME:-kubenet}"
# Specify the version of the istio addon to test
export ISTIO_ADDON_VERSION="${ISTIO_ADDON_VERSION:-asm-1-18}"

clusterNames=(
    "${OVERLAY_CILIUM_CLUSTER_NAME}"
    "${OVERLAY_AZURE_CLUSTER_NAME}"
    "${DYNAMIC_AZURE_CLUSTER_NAME}"
    "${DYNAMIC_CILIUM_CLUSTER_NAME}"
    "${KUBENET_AZURE_CLUSTER_NAME}"
    "${CNI_AZURE_CLUSTER_NAME}"
)

for clusterName in "${clusterNames[@]}"
do
    if [[ $clusterName == *"dynamic"* ]]; then # dynamic-azure dynamic-overlay
        echo "Creating dynamic test nodepools"
        az aks nodepool add --cluster-name ${clusterName} -g "${RESOURCE_GROUP}" -n "${TEST_USER_NODE}" --mode User --node-vm-size Standard_D16_V3 --node-count 20 --vnet-subnet-id "${VNET_SUBNET_ID}" --pod-subnet-id "${POD_SUBNET_ID}" --max-pods 130
    elif [[ $clusterName == *"kubenet"* ]]; then #kubenet
        echo "Creating kubenet nodepools"
        # Kubenet can only have 400 nodes, systempool - 5, prom -1, userpool - 394
        az aks nodepool add --cluster-name ${clusterName} -g ${RESOURCE_GROUP} -n ${TEST_USER_NODE} --mode User --node-vm-size Standard_D16_V3 --node-count 20 --vnet-subnet-id "${KUBENET_VNET_SUBNET_ID}" --max-pods 166
    else # cni-azure overlay-azure overlay-cilium
        az aks nodepool add --cluster-name ${clusterName} -g ${RESOURCE_GROUP} -n ${TEST_USER_NODE} --mode User --node-vm-size Standard_D16_V3 --node-count 20 --max-pods 130
    fi
    kubectl config use-context ${clusterName}
    kubectl apply -f ../istio-install/base/templates/prometheus.yaml -n aks-istio-system

    echo "Running benchmark on cluster ${clusterName}"
    export CLUSTER_LABEL="${clusterName}"
    ./run_benchmark_job.sh

    echo "Cleaning up test"
    kubectl delete ns test
    kubectl delete -f ../istio-install/base/templates/prometheus.yaml -n aks-istio-system
    az aks nodepool delete --cluster-name $clusterName -g ${RESOURCE_GROUP} -n ${TEST_PROM_NODE}
    az aks nodepool delete --cluster-name $clusterName -g ${RESOURCE_GROUP} -n ${TEST_USER_NODE}
done

./generate_plots.sh