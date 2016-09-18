
#subinfo
run_num=03
sub_num=02
sub_prefix=sub_${sub_num}-run_${run_num}

#paths
main_dir=$(bash maindir.sh)
bids_dir="${main_dir}/BIDSforrest"
path2_subraw="${bids_dir}/raw/sub_02"
path2_subderiv="${bids_dir}/deriv/sub_${sub_num}/ses_video"

# files
bold=${path2_subraw}/sub_${sub_num}-ses_video-run_${run_num}-bold.nii.gz
anat=${path2_subraw}/sub_${sub_num}-anat.nii.gz
physio=${path2_subraw}/sub_${sub_num}-ses_video-run_0${run_num}-physio.tsv.gz

cd ${path2_subderiv}



# # # ===== DEOBLIQUE =====

# # # AFNI recommends (drop first 5 vols)
# 3dWarp -deoblique -verb -prefix ${sub_prefix}-bold_raw ${bold}'[5..$]'
# 3dWarp -deoblique -verb -prefix ${sub_prefix}-anat ${anat}


# # # # ===== OUTLIER VOLUMES =====

# # #Compute fraction of outlier voxels for each volume
# 3dToutcount -automask -fraction -polort 6 -legendre   \
#     ${sub_prefix}-bold_raw+orig > ${sub_prefix}-outlier_count.1D

# # #Make outlier censor file
# 1deval -a ${sub_prefix}-outlier_count.1D -expr "1-step(a-0.1)" \
#         > ${sub_prefix}-outlier_censor.1D


# # =========== DESPIKE  =============

# 3dDespike -NEW -nomask \
#     -prefix ${sub_prefix}-bold_despike+orig \
#             ${sub_prefix}-bold_raw+orig




# # =============== REGISTRATION OUTLINE =================== ###

# # align each vol to base 
# # align anat to mean vol

# # ==== ALIGN epi2base (estimate motion)  ====

# # def base volume
# 3dbucket -prefix ${sub_prefix}-base ${sub_prefix}-bold_despike+orig"[2]"

# # epi2base
# 3dvolreg -verbose -zpad 1 -cubic                            \
#          -1Dfile ${sub_prefix}-motion.1D                    \
#          -base ${sub_prefix}-base+orig                      \
#          -prefix ${sub_prefix}-bold_despike_inbase          \
#          ${sub_prefix}-bold_despike+orig


# # ==== ALIGN anat2base ====
# # output -anat2base

# # align anat2meanepi
# align_epi_anat.py -volreg off -tshift off  \
#         -epi_base mean -epi_strip 3dAutomask  \
#         -anat2epi -suffix 2meanepi            \
#         -anat ${sub_prefix}-anat+orig      \
#         -epi ${sub_prefix}-bold_despike_inbase+orig       
                              

# ## ## =============== WARP =================== ## ##


# # ============ WARP anat_orig2tlrc ================

# # warp anatomy to tlc
# @auto_tlrc -base TT_N27+tlrc -init_xform AUTO_CENTER  \
#            -no_pre -input ${sub_prefix}-anat2meanepi+orig


# ============ WARP bold_orig2tlrc ================
adwarp \
    -apar ${sub_prefix}-anat2meanepi+tlrc \
    -dpar ${sub_prefix}-bold_despike_inbase+orig \

