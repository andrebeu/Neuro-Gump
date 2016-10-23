# subinfo
sub1_num=${1}
sub2_num=${2}
run_num=${3}
# lphcg rphcg
roi=${4}

echo -e "\n -- phcg_slideISC.sh ${sub1_num} ${sub2_num} ${roi} -- \n"

# paths
bids_dir=$(bash bidsdir.sh)
deriv_dir="${bids_dir}/deriv"
preprocess_dir="${deriv_dir}/preprocess"
mask_dir="${deriv_dir}/masks"
slideISC_dir="${deriv_dir}/slideISC/sub_${sub1_num}"

# input 
sub1_bold="${mask_dir}/sub_${sub1_num}-run_${run_num}-${roi}_bold+tlrc"
sub2_bold="${mask_dir}/sub_${sub2_num}-run_${run_num}-${roi}_bold+tlrc"

# results dir
if ! [ -d ${slideISC_dir} ];then
    mkdir -p ${slideISC_dir}
fi

# # ================== ISC =================
result_prefix="sub_${sub1_num}-sub_${sub2_num}-run_${run_num}-roi_${roi}-slideISC"

window=29
nv=$(3dinfo -nv ${sub1_bold})
last=$(echo "${nv}-${window}" | bc)
# last=5

for a in $(seq 0 ${last});do
    
    b=$(echo "${a}+${window}" | bc)
    window_postfix="window_$(printf %03d ${a})to$(printf %03d ${b})"

    sub1_window="${sub1_bold}[${a}..${b}]"
    sub2_window="${sub2_bold}[${a}..${b}]"

    # ISC
    3dTcorrelate -automask \
        -prefix "${slideISC_dir}/${result_prefix}_raw-${window_postfix}" \
        ${sub1_window} ${sub2_window}

    # r2z transformation
    3dcalc -expr "atanh(a)" \
        -a "${slideISC_dir}/${result_prefix}_raw-${window_postfix}+tlrc" \
        -prefix "${slideISC_dir}/${result_prefix}_zsc-${window_postfix}" 

done







     
