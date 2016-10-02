serv_dir=srm254@hd-hni.cac.cornell.edu:/home/fs01/srm254/Forrest/BIDSforrest/deriv
mac_dir=~/Documents/fMRI/Forrest/from_serv

# rsync -vam --include='deriv/sub_??/ses_video/nodes/*' --exclude='deriv/sub_??/ses_video/preprocess/*'\
#         --exclude='deriv/sub_??/ses_video/sub_??-run_03-bold_final+tlrc.*' ${serv_dir} ${mac_dir}

# --include='deriv/sub_??/sub_0[1-2]/ses_video/sub_0[1-2]-run_03-????_FCzmap+tlrc.*'


rsync --update -vam \
        --exclude='deriv/sub_??/ses_video/preprocess/*' \
        --exclude='deriv/sub_??/ses_video/sub_??-run_03-bold_final+tlrc.*' \
        --exclude='deriv/sub_??/ses_video/nodes' \
        ${serv_dir} ${mac_dir}
