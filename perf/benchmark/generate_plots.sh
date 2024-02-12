#bin/bash

# Merges the csv files from the test runs into a single csv file
# And then runs the graph plotter to generate the plots

export CNI_AZURE_CLUSTER_NAME="${CNI_AZURE_CLUSTER_NAME:-cni-azure2}"
export DYNAMIC_AZURE_CLUSTER_NAME="${DYNAMIC_AZURE_CLUSTER_NAME:-dynamic-azure2}"
export DYNAMIC_CILIUM_CLUSTER_NAME="${DYNAMIC_CILIUM_CLUSTER_NAME:-dynamic-cilium2}"
export OVERLAY_AZURE_CLUSTER_NAME="${OVERLAY_AZURE_CLUSTER_NAME:-overlay-azure2}"
export OVERLAY_CILIUM_CLUSTER_NAME="${OVERLAY_CILIUM_CLUSTER_NAME:-overlay-cilium2}"
export KUBENET_AZURE_CLUSTER_NAME="${KUBENET_AZURE_CLUSTER_NAME:-kubenet}"

cluster_envs=(
    "${OVERLAY_CILIUM_CLUSTER_NAME}"
    "${OVERLAY_AZURE_CLUSTER_NAME}"
    "${DYNAMIC_AZURE_CLUSTER_NAME}"
    "${DYNAMIC_CILIUM_CLUSTER_NAME}"
    "${KUBENET_AZURE_CLUSTER_NAME}"
    "${CNI_AZURE_CLUSTER_NAME}"
)

new_file_path=/tmp
dirs=""
for env in "${cluster_envs[@]}"
do
    dir_name=$(find "/tmp/${env}" -mindepth 1 -printf '%s %p\n'|sort -nr|head -n 1 | cut -d ' ' -f2)
    dirs+="${dir_name} "
done

amalgamate_csv=$(python3 ./amalgamate_csvs.py --filepath="${new_file_path}" --dirs="${dirs[@]}" | cut -d']' -f2 )

export FILE_NAME="${amalgamate_csv}"

./run_graph_plotter.sh
