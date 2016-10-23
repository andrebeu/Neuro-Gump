import os, sys
from glob import glob as glob
from os.path import join as opj
from subprocess import call as subprocesscall

# for input sub1:
# run hpca_slideISC.sh on sub1 with every other sub2
# compute average across sub2s within each window
# output: average ISC corr map for each window of given sub1 with all other sub2s

# paths
if 'srm254' in os.getcwd().split('/'):
    print 'in srm'
    deriv_dir = "/home/fs01/srm254/Forrest/BIDSforrest/deriv"
elif 'tmp' in os.getcwd().split('/'):
    print 'in clust'
    path_list = glob("/tmp/*.hd-hni.cac.cornell.edu/BIDSforrest/deriv")
    assert len(path_list) == 1; deriv_dir = path_list[0]

# input
sub1 = int(sys.argv[1])
print "\n -- phcg_slideISC_loop.py sub_%.2i -- \n" % sub1


# options
rois = ['rphcg']
run = 3; nv = 433
window = 29 # NB inclusive
last_window = nv - window + 1

# everyone except sub1
group = [sub2 for sub2 in [1,2,4,5] if sub2 != sub1] 
for roi in rois:
    
    # run slideISC for each sub pair
    for sub2 in group:
        cmd_ISC = "bash phcg_slideISC.sh %.2i %.2i %.2i %s" \
                % (sub1, sub2, run, roi)
        subprocesscall(cmd_ISC, shell=True)
        # out: slideISC for every pair

    # results dir
    slideISC_dir = opj(deriv_dir, "slideISC", "sub_%.2i" % sub1)
    avg_slideISC_dir = opj(slideISC_dir,"avg")
    if not os.path.isdir(avg_slideISC_dir): 
        os.mkdir(avg_slideISC_dir)


    print "\n = = AVG W/I WINDOW = = sub_%.2i-roi_%s \n" % (sub1,roi)
    ## average within window across sub2
    # loop through each window, calculate window mean across sub2s
    for a in range(last_window):
        b = a + window
        window_postfix = "%.3ito%.3i" % (a,b)

        # avg_slideISC prefix
        result_prefix = "%s/sub_%.2i-run_%.2i-roi_%s-slideISC_avg-window_%s" \
            % (avg_slideISC_dir, sub1, run, roi, window_postfix)
        
        # list of files to average
        window_list = glob(opj(deriv_dir,"slideISC","sub_%.2i" % sub1,
            "sub_%.2i-sub_??-run_%.2i-roi_%s" % (sub1,run,roi) 
            + "-slideISC_zsc-window_%s+tlrc.HEAD" % window_postfix))

        # command for afni 3dMean
        cmd_3dMean = "3dMean -prefix %s " % result_prefix 
        for wind in window_list: cmd_3dMean += "%s " % wind
        # call afni 3dMean
        subprocesscall(cmd_3dMean, shell=True)


    print "\n = = BUCKETING = = sub_%.2i-roi_%s \n" % (sub1,roi)
    # put all windows for given sub1roi in a bucket
    all_windows = "%s/sub_%.2i-run_%.2i-roi_%s-slideISC_avg-window_???to???+tlrc.HEAD" \
            % (avg_slideISC_dir, sub1, run, roi)
    bucket_prefix = "%s/sub_%.2i-run_%.2i-roi_%s-slideISC_avg-bucket" \
            % (avg_slideISC_dir, sub1, run, roi)
    nifti_prefix = "%s/sub_%.2i-run_%.2i-roi_%s-slideISC_avg.nii.gz" \
            % (avg_slideISC_dir, sub1, run, roi)
    
    # call 3dbucket
    cmd_3dbucket = "3dbucket -prefix %s %s" % (bucket_prefix, all_windows)
    subprocesscall(cmd_3dbucket, shell=True)
    # call 3dAFNItoNIFTI
    cmd_3dAFNItoNIFTI = "3dAFNItoNIFTI -prefix %s %s+tlrc" % (nifti_prefix, bucket_prefix)
    subprocesscall(cmd_3dAFNItoNIFTI, shell=True)

