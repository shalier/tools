#bin/bash
rootDir=/tmp
clusterEnvs=(dynamic-cilium cni-azure dynamic-azure overlay-azure kubenet-azure)
for clusterEnv in "${clusterEnvs[@]}"
do
    fileName=$(find "${rootDir}"/"${clusterEnv}" -maxdepth 1 -printf '%s %p\n'|sort -nr|head -n 1 | cut -d ' ' -f2)
    python3 ./append_cluster_env.py --csv_filepath="${fileName}" --clusterEnv="${clusterEnv}"
done