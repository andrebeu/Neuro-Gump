



## correction for head motion 
# regress_censor_motion
## slice-acquisition time correction
# tshift
# spatial smoothing (6 mm FWHM Gaussian kernel)
# blur 
# high-pass temporal filtering (140 s period).
# regress_bandpass 1/140 ~= 0.0074 
    
# Aline to a standard anatomical (MNI152) brain
# volreg_tlrc_warp applies transformation computated on anat to epi
# "EPI transformation applied along with motion alignment"


# interpolate to 3-mm isotropic voxels

# do I need regress in -blocks?
# volreg align to third volume of run

## PATHS ## 
main_dir=$(bash maindir.sh)
bids_dir=${main_dir}/BIDSforrest


## loop runs
# for run_num in $(seq 1 8);do
#     echo ${run_num}
# done


path2_subraw="${bids_dir}/raw/sub_02"
run_num=3
sub_num=${path2_subraw##*sub_}

bold=${path2_subraw}/sub_${sub_num}-ses_video-run_0${run_num}-bold.nii.gz
anat=${path2_subraw}/sub_${sub_num}-anat.nii.gz
physio=${path2_subraw}/sub_${sub_num}-ses_video-run_0${run_num}-physio.tsv.gz

path2_subderiv="${bids_dir}/deriv/sub_${sub_num}/ses_video"
cd ${path2_subderiv}





afni_proc.py -subj_id sub_${sub_num}-run_${run_num}   \
          -dsets ${bold} -copy_anat ${anat}    \
          -blocks despike tshift align tlrc volreg blur regress \
          \
          -blur_size 6  \
          -tcat_remove_first_trs 5  \
          -volreg_tlrc_warp   \
          -volreg_align_e2a    \
          \
          -regress_censor_motion 0.2  \
          -regress_censor_outliers 0.1    \
          -regress_bandpass 0.00714 99999   \
          -regress_apply_mot_types demean deriv  \
          \
          -regress_run_clustsim no  \
          # -regress_est_blur_epits                                    \
          # -regress_est_blur_errts

# run analysis
tcsh -xef proc.sub_02-run_3 2>&1 | tee output.proc.sub_02-run_3



# errts is the timeseries residual after removing modeled components
# AFNI recomends censoring motion at .2 for resting state
# epits contains everything, errts is motion censored
# regress_est_blur_epits estimate smoothness of epi data