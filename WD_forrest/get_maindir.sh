## MAC OR SERV ## 
if [[ $(pwd) == *"andre"* ]]; then
    main_dir="/Users/andrebeukers/Documents/fMRI/Forrest"
fi
if [[ $(pwd) == *"srm"* ]]; then
    main_dir="/home/fs01/srm254/Forrest"
fi
if [[ $(pwd) == *"tmp"* ]]; then
    main_dir="/tmp/*.hd-hni.cac.cornell.edu"
fi

echo ${main_dir}