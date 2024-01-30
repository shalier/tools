import sys
import argparse
import pandas as pd

def main(argv):
    parser = argparse.ArgumentParser(
        "Istio performance benchmark CSV file append cluster environment to label.")
    parser.add_argument(
        "-c", "--csv_filepath", type=str, required=True,
        help="CSV file path")
    parser.add_argument(
        "--clusterEnv", type=str, required=True,)    args = parser.parse_args(argv)
    df = pd.read_csv(args.csv_filepath)
    labels=df.loc[:,'Labels'].values
    for i in range(len(labels)):
        label=labels[i]
        if args.clusterEnv not in label:
            label=label+"_"+args.clusterEnv
        if "nojitter" in label:
            label=label.replace("nojitter","nojit")
        labels[i]=label
    df.loc[:,'Labels']=labels
    df.to_csv(args.csv_filepath,index=False)
    # print(df.loc[:,'Labels'].values)
    ## Generating the telemetry labels for graph plottiing
    # scenario_label = ["jitter_baseline", "jitter_both", "nojit_baseline", "nojit_both"]
    # cluster_envs = ["dynamic-cilium", "cni-azure", "dynamic-azure", "overlay-azure"]
    # labels = "("
    # for scenario in scenario_label:
    #     for cluster_env in cluster_envs:
    #         labels+=scenario + "_" + cluster_env+","
    #     labels=labels[:len(labels)-1]+" "
    # print(labels)
if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
