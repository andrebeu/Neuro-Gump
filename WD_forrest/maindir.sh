## MAC OR SERV ## 
if [[ $(pwd) == *"srm"* ]]; then
    main_dir="/home/fs01/srm254/Forrest"
fi
if [[ $(pwd) == *"andre"* ]]; then
    main_dir="/Users/andrebeukers/Documents/fMRI/Forrest"
fi

echo ${main_dir}