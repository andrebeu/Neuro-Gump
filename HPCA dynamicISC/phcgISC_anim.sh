`which Xvfb` :1 -screen 0 1024x768x24 &
export AFNI_DETACH=NO

sub_num=05
plane="axial"

# if ${plane} == "axial";then
crop="28:84,33:157"
geom="450x950"
# if ${plane} == "saggital"; then
# crop="37:164,64:115"
# geom="950x450"

bids_dir=$(bash bidsdir.sh)
deriv_dir="${bids_dir}/deriv"
slideISC_dir="${deriv_dir}/slideISC/sub_${sub_num}"
avg_dir="${slideISC_dir}/avg"
results_dir="${slideISC_dir}/anim"
mkdir -p ${results_dir}

# input file
olay="sub_${sub_num}-run_03-roi_rphcg-slideISC_avg"

nv=$(3dinfo -nv ${avg_dir}/${olay}.nii.gz)
echo -e "\n nv is ${nv} \n"

for vol in $(seq 1 200);do

    echo "----------------"${vol}"----------------"
    saveas="${results_dir}/${olay}_${plane:0:3}-$(printf %03d ${vol}).png"
    
    DISPLAY=:1 afni -echo_edu \
         -com 'SWITCH_DIRECTORY A.All_Datasets' \
         -com 'OPEN_WINDOW A.'${plane}'image mont=3x3:3' \
         -com 'SWITCH_UNDERLAY A.TT_N27' \
         -com 'SWITCH_OVERLAY A.'${olay}'.nii.gz' \
         -com 'SET_SUB_BRICKS A 0 '${vol}' '${vol} \
         -com 'ALTER_WINDOW A.'${plane}'image crop='${crop} \
         -com 'ALTER_WINDOW A.'${plane}'image geom='${geom} \
         -com 'SET_XHAIRSA A OFF' \
         -com 'SET_DICOM_XYZ A -22 33 -4' \
         -com 'SET_THRESHNEW A 0.3' \
         -com 'SET_PBAR_NUMBER A.12' \
         -com 'SAVE_PNG A.'${plane}'image '${saveas} \
         -com 'QUIT' \
         ~/abin ${avg_dir}

done

# shuts down the instance
killall Xvfb 

# call movie maker
ipython phcg_img2mov.py ${sub_num}