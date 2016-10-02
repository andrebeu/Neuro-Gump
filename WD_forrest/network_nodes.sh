
# input
sub_prefix="${1}"
sub_num=$(expr ${sub_prefix##*sub_} : '\([0-9][0-9]\)')

# paths
main_dir=$(bash get_maindir.sh)
bids_dir="${main_dir}/BIDSforrest"
sub_deriv="${bids_dir}/deriv/sub_${sub_num}/ses_video"
bold="${sub_deriv}/${sub_prefix}-bold_final+tlrc"

# make results directory
node_dir="${sub_deriv}/nodes"
mkdir -p ${node_dir}
cd ${node_dir}


radius=5
# # ====== DMN A ===== # #

# PCC
3dmaskave -dball 10 54 26 ${radius} -quiet ${bold} > ${sub_prefix}-lPCC_ts.1D
3dmaskave -dball -10 53 26 ${radius} -quiet ${bold} > ${sub_prefix}-rPCC_ts.1D
3dmaskave -dball 0 53 26 ${radius} -quiet ${bold} > ${sub_prefix}-PCC_ts.1D

# IPL inferior parietal lobule
3dmaskave -dball 48 41 39 ${radius} -quiet ${bold} > ${sub_prefix}-lIPL_ts.1D
3dmaskave -dball -48 41 39 ${radius} -quiet ${bold} > ${sub_prefix}-rIPL_ts.1D

# mPFC
3dmaskave -dball 6 -49 12 ${radius} -quiet ${bold} > ${sub_prefix}-lPFC_ts.1D
3dmaskave -dball -6 -49 12 ${radius} -quiet ${bold} > ${sub_prefix}-rPFC_ts.1D


# # ====== auditory network ===== # #

# A1 (broadman 41)
3dmaskave -dball 47 26 11 ${radius} -quiet ${bold} > ${sub_prefix}-lA1_ts.1D
3dmaskave -dball -47 26 11 ${radius} -quiet ${bold} > ${sub_prefix}-rA1_ts.1D

# PCG precentral gyrus
3dmaskave -dball 44 8 38 ${radius} -quiet ${bold} > ${sub_prefix}-lPCG_ts.1D
3dmaskave -dball -44 8 38 ${radius} -quiet ${bold} > ${sub_prefix}-rPCG_ts.1D
