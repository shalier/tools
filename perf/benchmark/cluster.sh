for n in "${clusterNames[@]}"
do
    kubectl config use-context $n
    kubectl apply -f ../../../istio-1.16.0/samples/addons/prometheus.yaml
    ./run_benchmark_job.sh
done