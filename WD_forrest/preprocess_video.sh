
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


# # ===== DEOBLIQUE =====

# # AFNI recommends (drop first 5 vols)
3dWarp -deoblique -verb -prefix ${sub_prefix}-bold_raw ${bold}'[5..$]'
3dWarp -deoblique -verb -prefix ${sub_prefix}-anat ${anat}


# # ===== OUTLIER VOLUMES =====

# #Compute fraction of outlier voxels for each volume
3dToutcount -automask -fraction -polort 6 -legendre   \
    ${sub_prefix}-bold_raw+orig > ${sub_prefix}-outlier_count.1D

# #Make outlier censor file
1deval -a ${sub_prefix}-outlier_count.1D -expr "1-step(a-0.1)" \
        > ${sub_prefix}-outlier_censor.1D


# =========== DESPIKE  =============

3dDespike -NEW -nomask \
    -prefix ${sub_prefix}-bold_despike+orig \
            ${sub_prefix}-bold_raw+orig


## =============== REGISTER =================== ###

align each dset to base volume, align to anat, warp to tlrc space


## ===== REGISTRATION BASE =====

3dbucket -prefix ${sub_prefix}-base ${sub_prefix}-bold_despike+orig"[2]"


#========== ALIGN anat2base =============

#compute params and align anat to epi
#NB aligned anat not used
#output skull stripped anat: ${sub_prefix}-anat_ns+orig 
# anat_ns+orig NOT ALIGNED TO BASE
#output anat2base matrix 
#Why is anat2base matrix useful?

align_epi_anat.py -anat2epi                       \
       -anat ${sub_prefix}-anat+orig              \
       -epi ${sub_prefix}-base+orig -epi_base 0   \
       -epi_strip 3dAutomask                      \
       -suffix 2base                              \
       -save_skullstrip -volreg off -tshift off   \
       

# # ====== ALIGN epi2base =======
# align each EPI volume to the base volume
# get motion matrix
# (why not use algin_epi_anat.py?)

3dvolreg -verbose -zpad 1 -cubic                            \
         \
         -1Dfile ${sub_prefix}-motion.1D                    \
         -1Dmatrix_save ${sub_prefix}-epi2base_mat.aff12.1D \
         \
         -base ${sub_prefix}-base+orig                      \
         -prefix ${sub_prefix}-bold_inbase                  \
         ${sub_prefix}-bold_despike+orig



# # ============ WARP anat_orig2tlrc ================

# # warp anatomy to tlc
# @auto_tlrc -base TT_N27+tlrc -input ${sub_prefix}-anat_ns+orig \
#            -no_ss -no_pre -init_xform AUTO_CENTER 

# # output: anat.Xat.1d encodes same as anat_ns+tlrc::WARP_DATA -I
# # this is the anat_orig2tlrc transformation for anat
# # (i.e. forward transformation matrix)
# cat_matvec ${sub_prefix}-anat_ns+tlrc::WARP_DATA -I \
#          > ${sub_prefix}-anat_orig2tlrc_mat.aff12.1D


# # ============ MAT mat_full.aff12  ============
# # catenate volreg/epi2anat/tlrc xforms
# # catenate matrices: anat_orig2tlrc, anat2base, epi2base 
# # If I catenate, don't I lose info about which transformation is which?

# # ORIG
# # cat_matvec -ONELINE                                         \
# #            ${sub_prefix}-anat_ns+tlrc::WARP_DATA -I         \
# #            ${sub_prefix}-anat2base_mat.aff12.1D -I          \
# #            ${sub_prefix}-epi2base_mat.aff12.1D              \
# #            > ${sub_prefix}-mat_full.aff12.1D

# # TROUBLESHOOT
# cat_matvec -ONELINE                                         \
#            ${sub_prefix}-anat_ns+tlrc::WARP_DATA -I         \
#            > ${sub_prefix}-mat_full.aff12.1D





# ## ====== WARP bold_orig2tlrc ====== ## 
# # apply mat_full.aff12

# # uses transformation in full_mat.aff12, coordinates in anat+tlrc 
# # why not use algin_epi_anat.py?

# 3dAllineate -base ${sub_prefix}-anat_ns+tlrc                   \
#             -input ${sub_prefix}-bold_inbase+orig             \
#             -1Dmatrix_apply ${sub_prefix}-mat_full.aff12.1D    \
#             -mast_dxyz 3                                       \
#             -prefix ${sub_prefix}-bold_inbase_intlrc



# #======= MASK all1 "extents"  =========

# # make an extents intersection mask 
# # mask of voxels that have valid data at every TR
# # (delete any time series with missing data)

# # #create an all-1 dataset to "mask the extents of the warp"
# 3dcalc -overwrite -a ${sub_prefix}-bold_despike+orig -expr 1   \
#        -prefix ${sub_prefix}-mask_epiall1

# # mask2tlrc
# # Why not make an all-1 from the +tlrc?
# 3dAllineate -base ${sub_prefix}-anat_ns+tlrc                      \
#             -input ${sub_prefix}-mask_epiall1+orig                \
#             -1Dmatrix_apply ${sub_prefix}-mat_full.aff12.1D       \
#             -mast_dxyz 3 -final NN -quiet                         \
#             -prefix ${sub_prefix}-mask_epiall1

# # get min from mask
# 3dTstat -prefix ${sub_prefix}-mask_minall1 -min \
#                 ${sub_prefix}-mask_epiall1+tlrc

# # rename mask
# 3dcopy ${sub_prefix}-mask_minall1+tlrc \
#        ${sub_prefix}-mask_extents

# # apply mask to unblurred bold
# 3dcalc -a ${sub_prefix}-bold_nomask+tlrc  \
#        -b ${sub_prefix}-mask_extents+tlrc \
#        -expr 'a*b' -prefix ${sub_prefix}-bold_masked


# # ================= BLUR ================ # #
# # why blur bold_masked and then mask that result again?

# # blur bold_masked
# 3dmerge -1blur_fwhm 6 -doall                    \
#         -prefix ${sub_prefix}-bold_blur_temp    \
#         ${sub_prefix}-bold_masked+tlrc

# # apply extents mask, "since no scale block"
# 3dcalc -a ${sub_prefix}-bold_blur_temp+tlrc \
#        -b ${sub_prefix}-mask_extents+tlrc   \
#        -expr 'a*b' -prefix ${sub_prefix}-bold_mask_blur


# # =========== CENSOR FILES ============= # #

# # creates binary censor file ${sub_prefix}-motion_censor.1D
# 1d_tool.py -censor_motion 0.2 ${sub_prefix}-motion \
#     -infile ${sub_prefix}-motion.1D  \
#     -set_nruns 1  -show_censor_count -censor_prev_TR   

# # # combine motion and outlier censor files
# 1deval -a ${sub_prefix}-motion_censor.1D -b ${sub_prefix}-outlier_censor.1D \
#        -expr "a*b" > ${sub_prefix}-combined_censor.1D


# # ================== REGRESS =================

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


