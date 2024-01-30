#!/bin/bash
export FILE_NAME="${FILE_NAME:-""}"

graph_type=(latency-p50 latency-p90 latency-p99) # cpu-client cpu-server mem-client mem-server
xaxis=(qps conn)
telemetry_modes=(jitter_baseline_dynamic-cilium,jitter_baseline_cni-azure,jitter_baseline_dynamic-azure,jitter_baseline_overlay-azure jitter_both_dynamic-cilium,jitter_both_cni-azure,jitter_both_dynamic-azure,jitter_both_overlay-azure nojit_baseline_dynamic-cilium,nojit_baseline_cni-azure,nojit_baseline_dynamic-azure,nojit_baseline_overlay-azure nojit_both_dynamic-cilium,nojit_both_cni-azure,nojit_both_dynamic-azure,nojit_both_overlay-azure)
conn_query_list="2,4,8,16,32,64"
qps_query_list="10,100,200,400,800,1000,1200,1400,1600,1800,2000"
conn_query_str=ActualQPS==1000
qps_query_str=NumThreads==16

if [[ -z "$FILE_NAME" ]]; then
    echo "FILE_NAME not set"
    exit 1
fi

for type in "${graph_type[@]}"
do
    for x in "${xaxis[@]}"
    do
        for mode in "${telemetry_modes[@]}"
        do
            scenarioLabel=$(echo ${mode}| cut -d',' -f1 | cut -d'_' -f-2)
            if [ "${x}" == "conn" ]; then
                python3 ./graph_plotter/graph_plotter.py --graph_type="${type}" --x_axis=conn --telemetry_modes="${mode}" --query_list="${conn_query_list}" --query_str="${conn_query_str}" --csv_filepath="${FILE_NAME}" --graph_title=graph_plots/"${type}"_"${scenarioLabel}"_1000qps.png
            else
                python3 ./graph_plotter/graph_plotter.py --graph_type="${type}" --x_axis=qps --telemetry_modes="${mode}" --query_list="${qps_query_list}"  --query_str="${qps_query_str}" --csv_filepath="${FILE_NAME}" --graph_title=graph_plots/"${type}"_16conn.png
            fi
        done
    done
done
