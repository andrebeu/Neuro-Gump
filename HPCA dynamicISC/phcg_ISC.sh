echo -e "\n -- phcg_ISC.sh -- \n"

# subinfo
sub1_num=${1}
sub2_num=${2}
run_num=${3}
# lphcg rphcg
roi=${4}

# paths
main_dir=$(bash get_maindir.sh)
deriv_dir="${main_dir}/BIDSforrest/deriv"
preprocess_dir="${deriv_dir}/preprocess"
mask_dir="${deriv_dir}/masks"
ISC_dir="${deriv_dir}/ISC"

# input 
sub1_bold="${mask_dir}/sub_${sub1_num}-run_${run_num}-${roi}_bold+tlrc"
sub2_bold="${mask_dir}/sub_${sub2_num}-run_${run_num}-${roi}_bold+tlrc"

# results dir
if ! [ -d ${ISC_dir} ];then
    mkdir -p ${ISC_dir}
fi

# # ================== ISC =================
result_prefix="sub_${sub1_num}-sub_${sub2_num}-run_${run_num}-roi_${roi}-ISC"

# ISC
3dTcorrelate -automask \
    -prefix "${ISC_dir}/${result_prefix}_raw" \
    ${sub1_bold} ${sub2_bold}

# r2z transformation
3dcalc -expr "atanh(a)" \
    -a "${ISC_dir}/${result_prefix}_raw+tlrc" \
    -prefix "${ISC_dir}/${result_prefix}_zsc" 
     
