serv_dir=srm254@hd-hni.cac.cornell.edu:/home/fs01/srm254/Forrest/BIDSforrest/deriv
mac_dir=~/Documents/fMRI/Forrest/from_serv

rsync -vam --update ${serv_dir}/* ${mac_dir}
