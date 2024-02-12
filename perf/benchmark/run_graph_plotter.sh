#!/bin/bash

# Runs the graph plotter to generate the plots for dynamic, overlay, and all clusters envs

export FILE_NAME="${FILE_NAME:-""}"
export CNI_AZURE_CLUSTER_NAME="${CNI_AZURE_CLUSTER_NAME:-cni-azure2}"
export DYNAMIC_AZURE_CLUSTER_NAME="${DYNAMIC_AZURE_CLUSTER_NAME:-dynamic-azure2}"
export DYNAMIC_CILIUM_CLUSTER_NAME="${DYNAMIC_CILIUM_CLUSTER_NAME:-dynamic-cilium2}"
export OVERLAY_AZURE_CLUSTER_NAME="${OVERLAY_AZURE_CLUSTER_NAME:-overlay-azure2}"
export OVERLAY_CILIUM_CLUSTER_NAME="${OVERLAY_CILIUM_CLUSTER_NAME:-overlay-cilium2}"
export KUBENET_AZURE_CLUSTER_NAME="${KUBENET_AZURE_CLUSTER_NAME:-kubenet}"

graph_type=(latency-p90 latency-p99) # cpu-client cpu-server mem-client mem-server latency-p50
xaxis=(qps conn)
conn_query_list="2,4,8,16,32,64"
qps_query_list="10,100,200,400,800,1000"
conn_query_str=ActualQPS==1000
qps_query_str=NumThreads==16

telemetry_modes=(__"${DYNAMIC_CILIUM_CLUSTER_NAME}"_baseline,__"${CNI_AZURE_CLUSTER_NAME}"_baseline,__"${DYNAMIC_AZURE_CLUSTER_NAME}"_baseline,__"${OVERLAY_AZURE_CLUSTER_NAME}"_baseline,__"${KUBENET_AZURE_CLUSTER_NAME}"_baseline,__"${OVERLAY_CILIUM_CLUSTER_NAME}"_baseline,__"${DYNAMIC_CILIUM_CLUSTER_NAME}"_both,__"${CNI_AZURE_CLUSTER_NAME}"_both,__"${DYNAMIC_AZURE_CLUSTER_NAME}"_both,__"${OVERLAY_AZURE_CLUSTER_NAME}"_both,__"${KUBENET_AZURE_CLUSTER_NAME}"_both,__"${OVERLAY_CILIUM_CLUSTER_NAME}"_both)
dynamic_w_cilium=(__"${DYNAMIC_AZURE_CLUSTER_NAME}"_baseline,__"${DYNAMIC_CILIUM_CLUSTER_NAME}"_baseline,__"${DYNAMIC_AZURE_CLUSTER_NAME}"_both,__"${DYNAMIC_CILIUM_CLUSTER_NAME}"_both)
overlay_w_cilium=(__"${OVERLAY_AZURE_CLUSTER_NAME}"_baseline,__"${OVERLAY_CILIUM_CLUSTER_NAME}"_baseline,__"${OVERLAY_AZURE_CLUSTER_NAME}"_both,__"${OVERLAY_CILIUM_CLUSTER_NAME}"_both)

if [[ -z "$FILE_NAME" ]]; then
    echo "FILE_NAME not set"
    exit 1
fi

for type in "${graph_type[@]}"
do
    for mode in "${dynamic_w_cilium[@]}"
    do
        scenario=$(echo "${mode}" | cut -d'_' -f1)
        w_sidecar=$(echo "${mode}" | rev | cut -d'_' -f1| rev)
        # python3 ./graph_plotter/graph_plotter.py --comparison=true --graph_type="${type}" --x_axis=qps --telemetry_modes="${mode}" --query_list="${qps_query_list}"  --query_str="${qps_query_str}" --csv_filepath="${FILE_NAME}" --comparison=true --graph_title=graph_plots/"${type}"_"${w_sidecar}"_"${scenario}"_dynamic_16conn.png
        python3 ./graph_plotter/graph_plotter.py --comparison=true  --graph_type="${type}" --x_axis=conn --telemetry_modes="${mode}" --query_list="${conn_query_list}" --query_str="${conn_query_str}" --csv_filepath="${FILE_NAME}" --graph_title=graph_plots/"${type}"_"${w_sidecar}"_"${scenario}"_dynamic_1000qps.png
    done
done
for type in "${graph_type[@]}"
do
    for mode in "${overlay_w_cilium[@]}"
    do
        scenario=$(echo "${mode}" | cut -d'_' -f1)
        w_sidecar=$(echo "${mode}" | rev | cut -d'_' -f1| rev)
        # python3 ./graph_plotter/graph_plotter.py --comparison=true --graph_type="${type}" --x_axis=qps --telemetry_modes="${mode}" --query_list="${qps_query_list}"  --query_str="${qps_query_str}" --csv_filepath="${FILE_NAME}" --graph_title=graph_plots/"${type}"_"${w_sidecar}"_"${scenario}"_overlay_16conn.png
        python3 ./graph_plotter/graph_plotter.py --comparison=true --graph_type="${type}" --x_axis=conn --telemetry_modes="${mode}" --query_list="${conn_query_list}" --query_str="${conn_query_str}" --csv_filepath="${FILE_NAME}" --graph_title=graph_plots/"${type}"_"${w_sidecar}"_"${scenario}"_overlay_1000qps.png
    done
done


for type in "${graph_type[@]}"
do
    for x in "${xaxis[@]}"
    do
        for mode in "${telemetry_modes[@]}"
        do
            scenario=$(echo "${mode}" | cut -d'_' -f1)
            w_sidecar=$(echo "${mode}" | rev | cut -d'_' -f1| rev)
            if [ "${x}" == "conn" ]; then
                python3 ./graph_plotter/graph_plotter.py --comparison=true --graph_type="${type}" --x_axis=conn --telemetry_modes="${mode}" --query_list="${conn_query_list}" --query_str="${conn_query_str}" --csv_filepath="${FILE_NAME}" --graph_title=graph_plots/"${type}"_"${scenario}"_1000qps.png
            # else
                # python3 ./graph_plotter/graph_plotter.py --graph_type="${type}" --x_axis=qps --telemetry_modes="${mode}" --query_list="${qps_query_list}"  --query_str="${qps_query_str}" --csv_filepath="${FILE_NAME}" --graph_title=graph_plots/"${type}"_"${w_sidecar}"_"${scenario}"_16conn.png
            fi
        done
    done
done
