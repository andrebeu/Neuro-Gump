
mkdir -p verb_dir

for s in $(seq 1 1); do
    sub_num=0${s}

    for r in $(seq 3 3);do
        run_num=0${r}

        #preprocess
        bash preprocess_video.sh ${sub_num} ${run_num} \
        &> verb_dir/${sub_num}-${run_num}-verb.txt
        
        # network nodes
        sub_prefix="sub_${sub_num}-run_${run_num}"
        bash network_nodes.sh ${sub_prefix}

    done
done
