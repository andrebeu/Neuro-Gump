
#subinfo
sub_num=${1}
run_num=${2}
sub_prefix=sub_${sub_num}-run_${run_num}

#paths
main_dir=$(bash get_maindir.sh)
bids_dir="${main_dir}/BIDSforrest"

# files
path2_subraw="${bids_dir}/raw/sub_${sub_num}"
bold=${path2_subraw}/sub_${sub_num}-ses_video-run_${run_num}-bold.nii.gz
anat=${path2_subraw}/sub_${sub_num}-anat.nii.gz


path2_deriv_preprocess="${bids_dir}/deriv/sub_${sub_num}/ses_video/preprocess"
mkdir -p ${path2_deriv_preprocess}
cd ${path2_deriv_preprocess}


# # # ===== DEOBLIQUE =====

# # # AFNI recommends (drop first 5 vols)
3dWarp -deoblique -verb -prefix ${sub_prefix}-bold_raw ${bold}'[5..$]'
3dWarp -deoblique -verb -prefix ${sub_prefix}-anat ${anat}


# # # =========== DESPIKE  =============
echo
echo DESPIKE
echo

3dDespike -NEW -nomask \
    -prefix ${sub_prefix}-bold_despike+orig \
            ${sub_prefix}-bold_raw+orig


# # =============== REGISTRATION  =================== ###
echo
echo REGISTRATION
echo

# # - align each vol to base 
# #    estimate motion
# # - align anat to mean vol

# # # ==== ALIGN bold   ====
# # # output -bold_despike_inbase

# # def base volume
3dbucket -prefix ${sub_prefix}-base ${sub_prefix}-bold_despike+orig"[2]"

# # epi2base
3dvolreg -verbose -zpad 1 -cubic                            \
         -1Dfile ${sub_prefix}-motion.1D                    \
         -base ${sub_prefix}-base+orig                      \
         -prefix ${sub_prefix}-bold_despike_inbase          \
         ${sub_prefix}-bold_despike+orig


# # ==== ALIGN anat ====
# # output -anat2meanepi

# align anat2meanepi
align_epi_anat.py -volreg off -tshift off  \
        -epi_base mean -epi_strip 3dAutomask  \
        -anat2epi -suffix 2meanepi            \
        -anat ${sub_prefix}-anat+orig      \
        -epi ${sub_prefix}-bold_despike_inbase+orig       
                              

## ## =============== WARP =================== ## ##
echo
echo WARP
echo

# # - warp anat 2 tlrc 
# # - warp bold 2 tlrc

# # ===== WARP anat_orig2tlrc =====

# warp anatomy to tlc
@auto_tlrc -base TT_N27+tlrc -init_xform AUTO_CENTER  \
           -no_pre -input ${sub_prefix}-anat2meanepi+orig


# ===== WARP bold_orig2tlrc ======
# uses matrix in anat

adwarp \
    -apar ${sub_prefix}-anat2meanepi+tlrc \
    -dpar ${sub_prefix}-bold_despike_inbase+orig 


# ================= BLUR ================ # #
echo
echo BLUR
echo

# blur bold 
3dmerge -1blur_fwhm 6 -doall               \
        -prefix ${sub_prefix}-bold_despike_inbase_blur    \
        ${sub_prefix}-bold_despike_inbase+tlrc


# =========== CENSOR FILES ============= # #
# drop outlier vols and motion

# -- # outlier volumes # -- #
# # compute fraction of outlier voxels for each volume
3dToutcount -automask -fraction -polort 6 -legendre \
    ${sub_prefix}-bold_raw+orig > ${sub_prefix}-outlier_count.1D

# # outlier censor file
1deval -a ${sub_prefix}-outlier_count.1D -expr "1-step(a-0.1)" \
        > ${sub_prefix}-outlier_censor.1D

# -- # motion # -- #
# creates binary censor file ${sub_prefix}-motion_censor.1D
1d_tool.py -censor_motion 0.2 ${sub_prefix}-motion \
    -infile ${sub_prefix}-motion.1D                \
    -set_nruns 1 -show_censor_count -censor_prev_TR   

# # combine motion and outlier censor files
1deval -a ${sub_prefix}-motion_censor.1D -b ${sub_prefix}-outlier_censor.1D \
       -expr "a*b" > ${sub_prefix}-combined_censor.1D


# # ================== REGRESS =================
echo
echo REGRESS
echo

# compute de-meaned motion parameters (for use in regression)
1d_tool.py -demean -set_nruns 1 \
        -infile ${sub_prefix}-motion.1D \
        -write ${sub_prefix}-motion_demean.1D

# compute motion parameter derivatives (for use in regression)
1d_tool.py -derivative -demean -set_nruns 1 \
        -infile ${sub_prefix}-motion.1D \
        -write ${sub_prefix}-motion_deriv.1D

# # create BANDPASS regressors (instead of using 3dBandpass)
# 1dBport -nodata 433 2.000001 -band 0.00714 99999 -invert -nozero  \
#     > ${sub_prefix}-bandpass.1D
# ## -ortvec ${sub_prefix}-bandpass.1D bandpass                            \

# run the regression analysis 
# output: regression matrix 

3dDeconvolve -input ${sub_prefix}-bold_despike_inbase_blur+tlrc \
    -censor ${sub_prefix}-combined_censor.1D                    \
    -polort A        \
    -num_stimts 12   \
    -stim_file 1 ${sub_prefix}-motion_demean.1D'[0]' -stim_base 1 -stim_label 1 roll  \
    -stim_file 2 ${sub_prefix}-motion_demean.1D'[1]' -stim_base 2 -stim_label 2 pitch \
    -stim_file 3 ${sub_prefix}-motion_demean.1D'[2]' -stim_base 3 -stim_label 3 yaw   \
    -stim_file 4 ${sub_prefix}-motion_demean.1D'[3]' -stim_base 4 -stim_label 4 dS    \
    -stim_file 5 ${sub_prefix}-motion_demean.1D'[4]' -stim_base 5 -stim_label 5 dL    \
    -stim_file 6 ${sub_prefix}-motion_demean.1D'[5]' -stim_base 6 -stim_label 6 dP    \
    -stim_file 7 ${sub_prefix}-motion_deriv.1D'[0]' -stim_base 7 -stim_label 7 d_roll   \
    -stim_file 8 ${sub_prefix}-motion_deriv.1D'[1]' -stim_base 8 -stim_label 8 d_pitch  \
    -stim_file 9 ${sub_prefix}-motion_deriv.1D'[2]' -stim_base 9 -stim_label 9 d_yaw    \
    -stim_file 10 ${sub_prefix}-motion_deriv.1D'[3]' -stim_base 10 -stim_label 10 d_dS  \
    -stim_file 11 ${sub_prefix}-motion_deriv.1D'[4]' -stim_base 11 -stim_label 11 d_dL  \
    -stim_file 12 ${sub_prefix}-motion_deriv.1D'[5]' -stim_base 12 -stim_label 12 d_dP  \
    -x1D_uncensored ${sub_prefix}-Xmat_uncensored.1D    \
    -x1D ${sub_prefix} \
    -x1D_stop


# display any large pairwise correlations from the X-matrix
1d_tool.py -show_cormat_warnings -infile ${sub_prefix}.xmat.1D &> ${sub_prefix}-corr_xmat_warn.txt

# # ================== PROJECT OUT =================
echo
echo PROJECT 
echo a

3dTproject -polort 0  \
       -input ${sub_prefix}-bold_despike_inbase_blur+tlrc.HEAD \
       -censor ${sub_prefix}-combined_censor.1D \
       -cenmode NTRP        \
       -stopband 0 0.00714  \
       -ort ${sub_prefix}-Xmat_uncensored.1D    \
       -prefix ${sub_prefix}-bold_final

## == == MOVING RESULTS == == ## 

mv ${sub_prefix}-bold_final* ..


