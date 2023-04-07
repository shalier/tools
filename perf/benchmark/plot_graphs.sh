#!/bin/bash
graph_type=(latency-p99 latency-p999 cpu-client cpu-server mem-client mem-server)
xaxis=(qps conn)

telemetry_modes="none_tcp_mtls_both,none_tcp_mtls_baseline,none_mtls_both,none_mtls_baseline"
conn_query_list="2,4,8,16,32,64"
qps_query_list="10,100,200,400,800,1000"
conn_query_str=ActualQPS==1000
qps_query_str=NumThreads==16

for type in "${graph_type[@]}"
do
    for x in "${xaxis[@]}"
    do
        if [ "${x}" == "conn" ]; then
            python3 ./graph_plotter/graph_plotter.py --graph_type="${type}" --x_axis=conn --telemetry_modes="${telemetry_modes}" --query_list="${conn_query_list}" --query_str="${conn_query_str}" --csv_filepath=/tmp/benchmark_HpOs.csv --graph_title=graph_plots/"${type}"_1000qps.png
        else
            python3 ./graph_plotter/graph_plotter.py --graph_type="${type}" --x_axis=qps --telemetry_modes="${telemetry_modes}" --query_list="${qps_query_list}"  --query_str="${qps_query_str}" --csv_filepath=/tmp/benchmark_HpOs.csv --graph_title=graph_plots/"${type}"_16conn.png
        fi
    done
done