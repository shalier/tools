#!/bin/bash


python3 ./graph_plotter.py \
--graph_type=latency-p50 \
--x_axis=conn \
--telemetry_modes=none_mtls_baseline\
--query_list=2,4,8,16,32,64 \
--query_str=ActualQPS==1000 \
--csv_filepath=/tmp/merged.csv \
--graph_title=./example_plot/plotter_output1.png

python3 ./graph_plotter.py \
--graph_type=cpu-client \
--x_axis=conn \
--telemetry_modes= v2-stats-wasm_both,v2-stats-nullvm_both,v2-sd-nologging-nullvm_both,v2-sd-full-nullvm_both,none_security_peer_authn_both,none_security_authz_path_both,none_security_authz_jwt_both,none_security_authz_ip_both,v2-sd-full-nullvm_security_authz_dry_run,none_tcp_mtls_both,none_tcp_mtls_baseline,none_mtls_both,none_mtls_baseline\
--query_list=2,4,8,16,32,64 \
--query_str=ActualQPS==1000 \
--csv_filepath=/tmp/merged.csv \
--graph_title=./example_plot/plotter_output2.png