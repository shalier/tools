#!/bin/bash


# python3 ./graph_plotter.py \
# --graph_type=latency-p50 \
# --x_axis=conn \
# --telemetry_modes=none_mtls_baseline\
# --query_list=2,4,8,16,32,64 \
# --query_str=ActualQPS==1000 \
# --csv_filepath=/tmp/merged.csv \
# --graph_title=./example_plot/plotter_output1.png

python3 ./graph_plotter.py \
--graph_type=latency-p99 \
--x_axis=qps \
--telemetry_modes=jitter_baseline_dynamic-cilium \
--query_list=10,100,200,400,800,1000 \
--query_str=NumThreads==16 \
--csv_filepath=/tmp/dynamic-cilium/benchmark_sSro.csv \
--graph_title=./example_plot/plotter_output2.png