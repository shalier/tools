#done cni-azure 
clusterNames=(kubenet-azure overlay-azure dynamic-azure dynamic-cilium overlay2-cilium)
# for n in "${clusterNames[@]}"
# do
#     az aks get-credentials \
#         --resource-group xiarg \
#         --name ${n}
# done
for n in "${clusterNames[@]}"
do
    kubectl config use-context $n
    kubectl apply -f ../../../istio-1.16.0/samples/addons/prometheus.yaml
    ./run_benchmark_job.sh -l $n
done