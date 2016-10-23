print "\n -- phcg_ISCmask.py -- \n"

import os, sys
from glob import glob as glob
from os.path import join as opj
from subprocess import call as subprocesscall


# run the hpca_ISC.sh on every pair of subject, take average
# output: average ISC corr map between sub1 and everyone else

if 'srm254' in os.getcwd().split('/'):
    deriv_dir = "/home/fs01/srm254/Forrest/BIDSforrest/deriv"
elif 'tmp' in os.getcwd().split('/'):
    path_list = glob("/tmp/*.hd-hni.cac.cornell.edu/BIDSforrest/deriv")
    assert len(path_list) == 1; deriv_dir = path_list[0]


sub1 = int(sys.argv[1])
group = [sub2 for sub2 in range(6)[1:] if sub2 != sub1]
run = 3

    
for roi in ['lphcg','rphcg']:
    
    # run ISC for each sub pair
    for sub2 in group:
        print sub1,sub2,roi
        cmd_ISC = "bash phcg_ISC.sh %.2i %.2i %.2i %s" \
                % (sub1, sub2, run, roi)
        subprocesscall(cmd_ISC, shell=True) 

    # average ISC 
    print "\n = = AVG MAKS = = \n"
    ISClist = glob(opj(deriv_dir, "ISC",
        "sub_%.2i-sub_*-run_%.2i-roi_%s-ISC_zsc+tlrc.HEAD" 
        % (sub1, run, roi)))
    cmd_3dMean = "3dMean -prefix %s/sub_%.2i-run_%.2i-roi_%s-ISC_avg " \
        % (opj(deriv_dir, "ISC"), sub1, run, roi)
    for sub in ISClist: cmd_3dMean += "%s " % sub
  
    print ISClist
    print cmd_3dMean
    subprocesscall(cmd_3dMean, shell=True) 


