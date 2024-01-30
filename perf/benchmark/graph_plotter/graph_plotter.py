# Copyright Istio Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import sys
import argparse
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.axes as axes
import numpy as np
import random
import math

metric_dict = {"cpu-client": "cpu_mili_avg_istio_proxy_fortioclient",
               "cpu-server": "cpu_mili_avg_istio_proxy_fortioserver",
               "cpu-ingressgateway": "cpu_mili_avg_istio_proxy_istio-ingressgateway",
               "mem-client": "mem_Mi_avg_istio_proxy_fortioclient",
               "mem-server": "mem_Mi_avg_istio_proxy_fortioserver",
               "mem-ingressgateway": "mem_Mi_avg_istio_proxy_istio-ingressgateway"}


def plotter(args):
    check_if_args_provided(args)
    print("csv_filepath", args.csv_filepath)
    df = pd.read_csv(args.csv_filepath.strip())
    telemetry_modes_y_data = {}
    metric_name = get_metric_name(args)
    constructed_query_str = get_constructed_query_str(args)

    # print("query string",constructed_query_str)
    for telemetry_mode in args.telemetry_modes:
        telemetry_modes_y_data[telemetry_mode] = get_data_helper(df, args.query_list, constructed_query_str,
                                                                 telemetry_mode, metric_name)

    dpi = 100
    plt.figure(figsize=(1138 / dpi, 871 / dpi), dpi=dpi)
    max_val=1
    print("telemetry_modes_y_data",telemetry_modes_y_data)

    for index, (key, val) in enumerate(telemetry_modes_y_data.items()):
        print("index",index,"key",key,"val",val)
        # creates the label for whether baseline/both and jitter/no_jitter
        scenario_label,title_label = get_scenario_label(key)
        print(scenario_label)
        cluster_env=key.replace(scenario_label+"_",'')
        print(cluster_env)
        max_val=max(max(val), max_val)
        num_x=len(val)
        plt.plot(np.arange(num_x), val, marker='o', label=cluster_env)
        ax=plt.gca()
        ax.xaxis.set_ticks(np.arange(num_x))
        ax.xaxis.set_ticklabels(args.query_list)
        z=random.uniform(-0.2,0.2)
        for x,y in zip(np.arange(num_x), val):
            if y is None or x is None:
                continue
            ax.annotate(y, xy=(x,y+index%3*z)) 
    box=ax.get_position()
    ax.set_position([box.x0, box.y0, box.width * 0.8, box.height])
    ax.legend(loc='center left', bbox_to_anchor=(1, 0.5))

    plt.xlabel(get_x_label(args))
    plt.ylabel(get_y_label(args))
    plt.ylim(0,max_val+1)
    plt.grid()
    plt.title(get_title(args)+"\n"+title_label)
    plt.savefig(args.graph_title, dpi=dpi)
    # plt.show()


# Helpers
def check_if_args_provided(args):
    args_all_provided = True
    print(vars(args))
    for _, val in vars(args).items():
        if val == "":
            print("Warning: There is at least one argument that you did not specify with a value.\n")
            args_all_provided = False
    if not check_args_consistency(args):
        args_all_provided = False
    if not args_all_provided:
        sys.exit(-1)


def check_args_consistency(args):
    if args.x_axis == "conn" and not args.query_str.startswith("ActualQPS=="):
        print("Warning: your specified query_str does not match with the x_axis definition.")
        return False
    if args.x_axis == "qps" and not args.query_str.startswith("NumThreads=="):
        print("Warning: your specified query_str does not match with the x_axis definition.")
        return False
    return True


def get_scenario_label(key_str):
    if key_str.startswith("jitter_baseline"):
        return "jitter_baseline", "Baseline with Jitter"
    if key_str.startswith("nojit_baseline"):
        return "nojit_baseline","Baseline without Jitter"
    if key_str.startswith("jitter_both"):
        return "jitter_both","Sidecar Enabled with Jitter"
    if key_str.startswith("nojit_both"):
        return "nojit_both","Sidecar Enabled without Jitter"


def get_constructed_query_str(args):
    if args.x_axis == "qps":
        return 'ActualQPS==@ql and ' + args.query_str + ' and Labels.str.endswith(@telemetry_mode)'
    elif args.x_axis == "conn":
        return args.query_str + ' and NumThreads==@ql and Labels.str.endswith(@telemetry_mode)'
    return ""


def get_metric_name(args):
    print(args)
    if args.graph_type.startswith("latency"):
        return args.graph_type.split("-")[1]
    return metric_dict[args.graph_type]


def get_data_helper(df, query_list, query_str, telemetry_mode, metric_name):
    y_series_data = []

    for ql in query_list:
        data = df.query(query_str)
        try:
            data[metric_name].head().empty
        except KeyError as e:
            y_series_data.append(None)
        else:
            if not data[metric_name].head().empty:
                if metric_name.startswith('cpu') or metric_name.startswith('mem'):
                    y_series_data.append(data[metric_name].head(1).values[0])
                else:
                    y_series_data.append(data[metric_name].head(1).values[0] / 1000)
            else:
                y_series_data.append(None)

    return y_series_data


def get_title(args):
    if args.graph_type.startswith("latency"):
        titleArr=args.graph_type.split("-")
        title=titleArr[1].title()+" "+ titleArr[0].title()
        if args.query_str.startswith("NumThreads"):
            numThreads=args.query_str[args.query_str.rindex("==")+2:]
            title+=" At "+numThreads+" Client Connections"
        if args.query_str.startswith("ActualQPS=="):
            qps=args.query_str[args.query_str.rindex("==")+2:]
            title+=" At "+qps+" QPS"
        return title
    return ""


def get_x_label(args):
    if args.x_axis == "qps":
        return "QPS"
    if args.x_axis == "conn":
        return "Client Connections"
    return ""


def get_y_label(args):
    if args.graph_type.startswith("latency"):
        return 'Latency (ms)'
    if args.graph_type.startswith("cpu"):
        return 'istio-proxy average CPUs (milliseconds)'
    if args.graph_type.startswith("mem"):
        return "istio-proxy average Memory (Mi)"
    return ""


def int_list(lst):
    return [int(i) for i in lst.split(",")]


def string_list(lst):
    return [str(i) for i in lst.split(",")]


def get_parser():
    parser = argparse.ArgumentParser(
        "Istio performance benchmark CSV file graph plotter.")
    parser.add_argument(
        "--graph_type",
        help="Choose from one of them: [latency-p50, latency-p90, latency-p99, latency-p999, "
             "cpu-client, cpu-server, mem-client, mem-server, cpu-ingressgateway, mem-ingressgateway]."
    )
    parser.add_argument(
        "--x_axis",
        help="Either qps or conn.",
    )
    parser.add_argument(
        "--telemetry_modes",
        help="This is a list of perf test labels, currently it can be any combinations from the follow supported modes:"
             "[none_mtls_baseline, none_mtls_both, v2-sd-full-nullvm_both, v2-stats-nullvm_both, "
             "v2-stats-wasm_both, v2-sd-nologging-nullvm_both].",
        type=string_list
    )
    parser.add_argument(
        "--query_list",
        help="Specify the qps or conn range you want to plot based on the CSV file."
             "For example, conn_query_list=[2, 4, 8, 16, 32, 64], qps_query_list=[10, 100, 200, 400, 800, 1000].",
        type=int_list
    )
    parser.add_argument(
        "--query_str",
        help="Specify the qps or conn query_str that will be used to query your y-axis data based on the CSV file."
             "For example: conn_query_str=ActualQPS==1000, qps_query_str=NumThreads==16."
    )
    parser.add_argument(
        "--csv_filepath",
        help="The path of the CSV file."
    )
    parser.add_argument(
        "--graph_title",
        help="The graph title."
    )
    return parser


def main(argv):
    args = get_parser().parse_args(argv)
    return plotter(args)


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
