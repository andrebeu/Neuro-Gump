
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


# # # =========== DESPIKE  =============

# 3dDespike -NEW -nomask \
#     -prefix ${sub_prefix}-bold_despike+orig \
#             ${sub_prefix}-bold_raw+orig


# # # =============== REGISTRATION  =================== ###

# # # - align each vol to base 
# # #    estimate motion
# # # - align anat to mean vol

# # # ==== ALIGN bold   ====
# # # output -bold_despike_inbase

# # def base volume
# 3dbucket -prefix ${sub_prefix}-base ${sub_prefix}-bold_despike+orig"[2]"

# # epi2base
# 3dvolreg -verbose -zpad 1 -cubic                            \
#          -1Dfile ${sub_prefix}-motion.1D                    \
#          -base ${sub_prefix}-base+orig                      \
#          -prefix ${sub_prefix}-bold_despike_inbase          \
#          ${sub_prefix}-bold_despike+orig

# # # ==== ALIGN anat ====
# # # output -anat2meanepi

# # align anat2meanepi
# align_epi_anat.py -volreg off -tshift off  \
#         -epi_base mean -epi_strip 3dAutomask  \
#         -anat2epi -suffix 2meanepi            \
#         -anat ${sub_prefix}-anat+orig      \
#         -epi ${sub_prefix}-bold_despike_inbase+orig       
                              

# ## ## =============== WARP =================== ## ##

# # # - warp anat 2 tlrc 
# # # - warp bold 2 tlrc

# # # ===== WARP anat_orig2tlrc =====

# # warp anatomy to tlc
# @auto_tlrc -base TT_N27+tlrc -init_xform AUTO_CENTER  \
#            -no_pre -input ${sub_prefix}-anat2meanepi+orig


# ===== WARP bold_orig2tlrc ======
# uses anat

# adwarp \
#     -apar ${sub_prefix}-anat2meanepi+tlrc \
#     -dpar ${sub_prefix}-bold_despike_inbase+orig 



# # ================= BLUR ================ # #

# blur bold 
3dmerge -1blur_fwhm 6 -doall               \
        -prefix ${sub_prefix}-bold_blur    \
        ${sub_prefix}-bold_despike_inbase+tlrc


# # =========== CENSOR FILES ============= # #
# drop outlier vols and motion

# -- # outlier volumes # -- #
# # compute fraction of outlier voxels for each volume
3dToutcount -automask -fraction -polort 6 -legendre \
    ${sub_prefix}-bold_raw+orig > ${sub_prefix}-outlier_count.1D

# #Make outlier censor file
1deval -a ${sub_prefix}-outlier_count.1D -expr "1-step(a-0.1)" \
        > ${sub_prefix}-outlier_censor.1D

# -- # motion # -- #
# creates binary censor file ${sub_prefix}-motion_censor.1D
1d_tool.py -censor_motion 0.2 ${sub_prefix}-motion \
    -infile ${sub_prefix}-motion.1D  \
    -set_nruns 1  -show_censor_count -censor_prev_TR   

# # combine motion and outlier censor files
1deval -a ${sub_prefix}-motion_censor.1D -b ${sub_prefix}-outlier_censor.1D \
       -expr "a*b" > ${sub_prefix}-combined_censor.1D


# # # ================== REGRESS =================

# # compute de-meaned motion parameters (for use in regression)
# 1d_tool.py -demean -set_nruns 1 \
#         -infile ${sub_prefix}-motion.1D \
#         -write ${sub_prefix}-motion_demean.1D

# # compute motion parameter derivatives (for use in regression)
# 1d_tool.py -derivative -demean -set_nruns 1 \
#         -infile ${sub_prefix}-motion.1D \
#         -write ${sub_prefix}-motion_deriv.1D

# # create bandpass regressors (instead of using 3dBandpass, say)
# 1dBport -nodata 433 2.000001 -band 0.00714 99999 -invert -nozero  \
#     > ${sub_prefix}-bandpass.1D


# # run the regression analysis 
# # output: regression matrix 
# 3dDeconvolve -input ${sub_prefix}-bold_mask_blur+tlrc.HEAD                \
#     -censor ${sub_prefix}-combined_censor.1D                              \
#     -ortvec ${sub_prefix}-bandpass.1D bandpass                            \
#     -polort 6                                                             \
#     -num_stimts 12                                                        \
#     -stim_file 1 ${sub_prefix}-motion_demean.1D'[0]' -stim_base 1 -stim_label 1 roll_01  \
#     -stim_file 2 ${sub_prefix}-motion_demean.1D'[1]' -stim_base 2 -stim_label 2 pitch_01 \
#     -stim_file 3 ${sub_prefix}-motion_demean.1D'[2]' -stim_base 3 -stim_label 3 yaw_01   \
#     -stim_file 4 ${sub_prefix}-motion_demean.1D'[3]' -stim_base 4 -stim_label 4 dS_01    \
#     -stim_file 5 ${sub_prefix}-motion_demean.1D'[4]' -stim_base 5 -stim_label 5 dL_01    \
#     -stim_file 6 ${sub_prefix}-motion_demean.1D'[5]' -stim_base 6 -stim_label 6 dP_01    \
#     -stim_file 7 ${sub_prefix}-motion_deriv.1D'[0]' -stim_base 7 -stim_label 7 roll_02   \
#     -stim_file 8 ${sub_prefix}-motion_deriv.1D'[1]' -stim_base 8 -stim_label 8 pitch_02  \
#     -stim_file 9 ${sub_prefix}-motion_deriv.1D'[2]' -stim_base 9 -stim_label 9 yaw_02    \
#     -stim_file 10 ${sub_prefix}-motion_deriv.1D'[3]' -stim_base 10 -stim_label 10 dS_02  \
#     -stim_file 11 ${sub_prefix}-motion_deriv.1D'[4]' -stim_base 11 -stim_label 11 dL_02  \
#     -stim_file 12 ${sub_prefix}-motion_deriv.1D'[5]' -stim_base 12 -stim_label 12 dP_02  \
#     -fitts ${sub_prefix}-fitts -errts ${sub_prefix}-errts  \
#     -fout -tout -x1D X.xmat.1D -xjpeg X.jpg                \
#     -x1D_uncensored Xmat_uncensored.1D                     \
#     -fitts ${sub_prefix}-fitts -errts ${sub_prefix}-errts  \
#     -bucket ${sub_prefix}-stats


# # display any large pairwise correlations from the X-matrix
# 1d_tool.py -show_cormat_warnings -infile X.xmat.1D &> out.cormat_warn.txt

# # -- project out regression matrix --
# 3dTproject -polort 0  \
#        -input ${sub_prefix}-bold_mask_blur+tlrc.HEAD \
#        -censor ${sub_prefix}-combined_censor.1D -cenmode ZERO \
#        -ort Xmat_uncensored.1D \
#        -prefix ${sub_prefix}-project_errts



# # ----------------------- QUALITY CONTROL ---------------------------
# # create a temporal signal to noise ratio dataset 
# #    signal: if 'scale' block, mean should be 100
# #    noise : compute standard deviation of errts

# # #note TRs that were not censored
# uncen_TRs=$(1d_tool.py -infile ${sub_prefix}-combined_censor.1D \
#             -show_trs_uncensored encoded)
# echo ${uncen_TRs} > ${sub_prefix}-TRs_uncensored.1d

# # compute SNR
# 3dTstat -mean -prefix ${sub_prefix}-signal ${sub_prefix}-bold_mask_blur+tlrc"[${uncen_TRs}]"
# 3dTstat -stdev -prefix ${sub_prefix}-noise ${sub_prefix}-errts+tlrc"[${uncen_TRs}]"

# 3dcalc -a ${sub_prefix}-signal+tlrc                                               \
#        -b ${sub_prefix}-noise+tlrc                                                \
#        -expr 'a/b' -prefix ${sub_prefix}-SNR


# # #========= FINAL ANAT & BASE ========= #

# # warp the volreg base EPI dataset to make a final version

# cat_matvec -ONELINE                                      \
#            ${sub_prefix}-anat_ns+tlrc::WARP_DATA -I       \
#            ${sub_prefix}-anat2base_mat.aff12.1D -I          \
#            > anat2tlrc_anat2base.aff12.1D

# # base2tlrc
# 3dAllineate -base ${sub_prefix}-anat_ns+tlrc                    \
#             -input ${sub_prefix}-base+orig                      \
#             -1Dmatrix_apply anat2tlrc_anat2base.aff12.1D   \
#             -mast_dxyz 3                                        \
#             -prefix ${sub_prefix}-base_final

# # # create an anat_final dataset, aligned with stats
# 3dcopy ${sub_prefix}-anat_ns+tlrc ${sub_prefix}-anat_final


