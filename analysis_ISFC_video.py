import os
from os.path import join as opj
import numpy as np

# # PATHS
if "andrebeukers" in os.getcwd():
    bids_dir = "/Users/andrebeukers/Documents/fMRI/Forrest/BIDSforrest"
elif "srm254" in os.getcwd():
    bids_dir = "/Users/andrebeukers/Documents/fMRI/Forrest/BIDSforrest"
elif "tmp" in os.getcwd():
    bids_dir = "/Users/andrebeukers/Documents/fMRI/Forrest/BIDSforrest"

# inputs
sub1 = 3
sub2 = 4
run = 3
node1 = "rPCC"
node2 = "rPCC"

# paths
deriv_dir1 = opj(bids_dir, "deriv", "sub_%.2i" % sub1, "ses_video")
node1_fpath = opj(deriv_dir1, "nodes", "sub_%.2i-run_%.2i-%s_ts.1D" % (sub1, run, node1))

deriv_dir2 = opj(bids_dir, "deriv", "sub_%.2i" % sub2, "ses_video")
node2_fpath = opj(deriv_dir2, "nodes", "sub_%.2i-run_%.2i-%s_ts.1D" % (sub2, run, node2))

# load from .1D to np array
node1_ts = np.genfromtxt(node1_fpath, delimiter=' ')
node2_ts = np.genfromtxt(node2_fpath, delimiter=' ')

# sliding window (in TRs) correlation
window_size = 60
corr = []
for t in range(len(node1_ts) - window_size):
    node1_ts_seg = node1_ts[ t : t+window_size ]
    node2_ts_seg = node2_ts[ t : t+window_size ]
    corr_seg = np.correlate(node1_ts_seg, node2_ts_seg)
    corr.extend(corr_seg)

# save results
result_fname = "ISFC-%ss%.2i-%ss%.2i-r%.2i" % (node1, sub1, node2, sub2, run)
result_fpath = opj(bids_dir, "deriv", "analysis_ISFC", result_fname)
np.savetxt(result_fpath, corr)
    
