
# input
sub_prefix=$1

# paths
main_dir=$(bash get_maindir.sh)
bids_dir="${main_dir}/BIDSforrest"
sub_num=$(expr ${sub1_prefix##*sub_} : '\([0-9][0-9]\)')
sub_deriv="${bids_dir}/deriv/sub_${sub_num}/ses_video"
cd ${sub_deriv}



radius=5
# # ====== DMN A ===== # #

# PCC
3dmaskave -dball 10 54 26 ${radius} -quiet ${sub_prefix}-bold_final+tlrc > ${sub_prefix}-lPCC_ts.1D
3dmaskave -dball -10 53 26 ${radius} -quiet ${sub_prefix}-bold_final+tlrc > ${sub_prefix}-rPCC_ts.1D

# IPL inferior parietal lobule
3dmaskave -dball 48 41 39 ${radius} -quiet ${sub_prefix}-bold_final+tlrc > ${sub_prefix}-lIPL_ts.1D
3dmaskave -dball -48 41 39 ${radius} -quiet ${sub_prefix}-bold_final+tlrc > ${sub_prefix}-rIPL_ts.1D


# # ====== auditory network ===== # #

# A1 (broadman 41)
3dmaskave -dball 47 26 11 ${radius} -quiet ${sub_prefix}-bold_final+tlrc > ${sub_prefix}-lA1_ts.1D
3dmaskave -dball -47 26 11 ${radius} -quiet ${sub_prefix}-bold_final+tlrc > ${sub_prefix}-rA1_ts.1D

# PCG precentral gyrus
3dmaskave -dball 44 8 38 ${radius} -quiet ${sub_prefix}-bold_final+tlrc > ${sub_prefix}-lPCG_ts.1D
3dmaskave -dball -44 8 38 ${radius} -quiet ${sub_prefix}-bold_final+tlrc > ${sub_prefix}-rPCG_ts.1D