
# PATHS
main_dir=$(bash get_maindir.sh)
DATAforrest="${main_dir}/DATAforrest"
BIDSforrest="${main_dir}/BIDSforrest"
# DATAforrest="/Volumes/EXT_DRIVE/DATAforrest"

## select subs
subs="[0-2][1-5]"


#loop through video_subs
for sub_audio in "${DATAforrest}"/audio_forrest/sub0${subs}; do
    
    sub_num=$(expr "${sub_audio}" : ".*\([0-9][0-9]\)")
    

    ## BIDS FOLDER STRUCTURE
    raw_folder="${BIDSforrest}/raw/sub_${sub_num}"
    mkdir -p ${raw_folder}
    audio_deriv_folder="${BIDSforrest}/deriv/sub_${sub_num}/ses_audio"
    mkdir -p ${audio_deriv_folder}

    ## ANAT 
    anat_old=${sub_audio}/anatomy/highres001.nii.gz
    anat_bids=${raw_folder}/sub_${sub_num}-anat.nii.gz
    rsync -vam "${anat_old}" "${anat_bids}"

        # echo "AUDIO BOLD"
        # path2_audio_bold_old="${path2_runfolder}/bold_dico_dico7Tad2grpbold7Tad_nl.nii.gz"
        # path2_audio_bold_bids="${path2_raw_subj_folder}/sub_${sub_num}-ses_audio-run_0${run_num}-bold.nii.gz"
        # rsync -vam ${path2_audio_bold_old} ${path2_audio_bold_bids}

        # echo "AUDIO MOCO"
        # path2_audio_moco_old="${path2_runfolder}/bold_dico_moco.txt"
        # path2_audio_moco_bids="${path2_raw_subj_folder}/sub_${sub_num}-ses_audio-run_0${run_num}-moco.txt"
        # rsync -vam ${path2_audio_moco_old} ${path2_audio_moco_bids}
done


# loop through video_subs
for sub_video in "${DATAforrest}"/video_forrest/sub-${subs}/ses-movie/func; do

    sub_num=$(expr "${sub_video}" : ".*\([0-9][0-9]\)")
    echo "VIDEO sub"${sub_num}
    
    # BIDS folders
    video_deriv_folder="${BIDSforrest}/deriv/sub_${sub_num}/ses_video"
    mkdir -p ${video_deriv_folder}
    video_ISFC_folder="${BIDSforrest}/deriv/sub_${sub_num}/ses_video/analysis_ISFC"
    mkdir -p ${video_ISFC_folder}

    for run_num in $(seq 1 8); do
        
        echo "run "${run_num}

        # echo "VIDEO BOLD"
        video_bold_old="${sub_video}/sub-${sub_num}_ses-movie_task-movie_run-${run_num}_bold.nii.gz"
        video_bold_bids="${BIDSforrest}/raw/sub_${sub_num}/sub_${sub_num}-ses_video-run_0${run_num}-bold.nii.gz"
        rsync -vam "${video_bold_old}" "${video_bold_bids}"

        # echo "VIDEO PHYSIO"
        # path2_video_physio_old="${path2_video_func}/sub-${sub_num}_ses-movie_task-movie_run-${run_num}_recording-cardresp_physio.tsv.gz"
        # path2_video_physio_bids="${path2_raw_subj_folder}/sub_${sub_num}-ses_video-run_0${run_num}-physio.tsv.gz"
        # rsync -vam "${path2_video_physio_old}" "${path2_video_physio_bids}"
        
    done

done

    

        


        



