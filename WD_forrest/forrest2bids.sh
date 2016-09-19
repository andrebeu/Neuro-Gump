

# PATHS
main_dir=$(bash maindir.sh)
path2_DATAforrest=${path2_maindir}/DATAforrest
path2_BIDSforrest=${path2_maindir}/BIDSforrest



# loop through subject folders
for sub in ${path2_DATAforrest}/sub0[0-2][2-3]; do

    # get subject number
    sub_num=$(expr "${sub}" : ".*\([0-9][0-9]\)")
    echo "subnum:"
    echo ${sub_num}

    ## RAW SUBJ FOLDER
    path2_raw_subj_folder="${path2_BIDSforrest}/raw/sub_${sub_num}"
    mkdir -p ${path2_raw_subj_folder}

    ## ANAT 
    path2_anat_old="${sub}/anatomy/highres001.nii.gz"
    path2_anat_bids="${path2_raw_subj_folder}/sub_${sub_num}-anat.nii.gz"
    rsync -vam ${path2_anat_old} ${path2_anat_bids}


    # loop through functional run folders
    for path2_runfolder in ${sub}/BOLD/task001_run00[3-4]; do
        
        run_num=$(expr ${path2_runfolder} : ".*run00\([1-9]\)")
        echo ${run_num}
        echo $sub_num
        

        ## MOVE AND RENAME DATA
        echo "AUDIO BOLD"
        path2_audio_bold_old="${path2_runfolder}/bold_dico_dico7Tad2grpbold7Tad_nl.nii.gz"
        path2_audio_bold_bids="${path2_raw_subj_folder}/sub_${sub_num}-ses_audio-run_0${run_num}-bold.nii.gz"
        rsync -vam ${path2_audio_bold_old} ${path2_audio_bold_bids}

        echo "AUDIO MOCO"
        path2_audio_moco_old="${path2_runfolder}/bold_dico_moco.txt"
        path2_audio_moco_bids="${path2_raw_subj_folder}/sub_${sub_num}-ses_audio-run_0${run_num}-moco.txt"
        rsync -vam ${path2_audio_moco_old} ${path2_audio_moco_bids}

        echo "VIDEO BOLD"
        path2_video_func="${path2_DATAforrest}/sub-${sub_num}/ses-movie/func"
        path2_video_bold_bids="${path2_raw_subj_folder}/sub_${sub_num}-ses_video-run_0${run_num}-bold.nii.gz"
        rsync -vam "${path2_video_func}/sub-${sub_num}_ses-movie_task-movie_run-${run_num}_bold.nii.gz" ${path2_video_bold_bids}

        echo "VIDEO PHYSIO"
        path2_video_physio_old="${path2_video_func}/sub-${sub_num}_ses-movie_task-movie_run-${run_num}_recording-cardresp_physio.tsv.gz"
        path2_video_physio_bids="${path2_raw_subj_folder}/sub_${sub_num}-ses_video-run_0${run_num}-physio.tsv.gz"
        rsync -vam "${path2_video_physio_old}" "${path2_video_physio_bids}"

        ## MAKE DERIV FOLDERS
        path2_audio_deriv_folder="${path2_BIDSforrest}/deriv/sub_${sub_num}/ses_audio"
        path2_video_deriv_folder="${path2_BIDSforrest}/deriv/sub_${sub_num}/ses_video"
        mkdir -p ${path2_audio_deriv_folder}
        mkdir -p ${path2_video_deriv_folder}
        

    done
done


