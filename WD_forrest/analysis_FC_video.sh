#subinfo
sub_prefix=${1}
node=${2}

#paths
main_dir=$(bash get_maindir.sh)
bids_dir="${main_dir}/BIDSforrest"

sub_num=$(expr ${sub_prefix##sub_} : '\([0-9][0-9]\)')
path2_deriv="${bids_dir}/deriv/sub_${sub_num}/ses_video"
cd ${path2_deriv}


# # ================== FC =================

# data
bold="${sub_prefix}-bold_final+tlrc"
pcc="nodes/${sub_prefix}-${node}_ts.1D"

# FC 
3dTcorr1D -prefix ${sub_prefix}-${node}_FCrmap ${bold} ${pcc}

# r to z transformation
numvol=$(3dinfo -nv ${bold})

3dcalc -prefix ${sub_prefix}-${node}_FCzmap \
    -a ${sub_prefix}-${node}_FCrmap+tlrc    \
    -expr "(atanh(a))/(1/sqrt(${numvol}-3))" 

