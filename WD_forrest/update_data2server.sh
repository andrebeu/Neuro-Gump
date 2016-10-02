
# path2_forrestdata_mac='/Users/andrebeukers/Documents/fMRI/Forrest/DATAforrest'
path2_forrestdata_drive="/Volumes/EXT_DRIVE/DATAforrest"
path2_forrestdata_serv="srm254@hd-hni.cac.cornell.edu:/home/fs01/srm254/Forrest/DATAforrest"

rsync -vam ${path2_forrestdata_drive}/* ${path2_forrestdata_serv}

