#bin/bash

new_file_path=/tmp
cluster_envs=(dynamic-cilium cni-azure dynamic-azure overlay-azure) # kubenet-azure still running
files=""
for env in "${cluster_envs[@]}"
do
    file_name=$(find "/tmp/${env}" -maxdepth 1 -printf '%s %p\n'|sort -nr|head -n 1 | cut -d ' ' -f2)
    files+="${file_name} "
done
# amalgamate_csv=$(python3 ./amalgamate_csvs.py --filepath="${new_file_path}" --files="${files[@]}" | cut -d']' -f2 )
amalgamate_csv=/tmp/amalgamatedResults32239.csv
echo -e "amalgamate_csv: ${amalgamate_csv}"
export FILE_NAME="${amalgamate_csv}"

./plot_graphs.sh
