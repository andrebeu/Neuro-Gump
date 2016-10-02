#!/bin/bash -l
#PBS -l nodes=1:ppn=5
#PBS -m e
#PBS -M andre.olibeu@gmail.com
#PBS -N Forrest
#PBS -j oe

set -x
pwd

# PATHS
main_dir="/home/fs01/srm254/Forrest"
wd_dir="${main_dir}/WD_forrest"
bids_dir="${main_dir}/BIDSforrest"

# upload anaconda
rsync -R ~/anaconda2 ${TMPDIR}
PATH=${TMPDIR}/anaconda2/bin:$PATH

# copy wd and data over to the compute node
rsync -va ${wd_dir} ${TMPDIR}
rsync -va ${bids_dir} ${TMPDIR}

# cd into WD, run script
cd ${TMPDIR}/${wd_dir##*/}
bash preprocess_video_loop.sh

# data back
rsync -va --update ${TMPDIR}/${bids_dir##*/}/* ${bids_dir}
rsync -va --update ${TMPDIR}/${wd_dir##*/}/verb_dir ${bids_dir}

