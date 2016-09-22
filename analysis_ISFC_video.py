import os
from os.path import join as opj
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import scipy as sc


# # PATHS
if "andrebeukers" in os.getcwd():
    bids_dir = "/Users/andrebeukers/Documents/fMRI/Forrest/BIDSforrest"
elif "srm254" in os.getcwd():
    bids_dir = "/Users/andrebeukers/Documents/fMRI/Forrest/BIDSforrest"
elif "tmp" in os.getcwd():
    bids_dir = "/Users/andrebeukers/Documents/fMRI/Forrest/BIDSforrest"

sub=1; run=3; node='rPCC'


def get_node_ts(sub,run,node):
    global bids_dir
    deriv_dir = opj(bids_dir, "deriv", "sub_%.2i" % sub, "ses_video")
    node_fpath = opj(deriv_dir, "nodes", "sub_%.2i-run_%.2i-%s_ts.1D" % (sub, run, node))
    print node_fpath
    node_ts = pd.read_csv(node_fpath, delimiter=' ', header=None)
    z_node_ts = sc.stats.zscore(node_ts.iloc[:,0].values)
    return z_node_ts

ts1 = get_node_ts(1,run,node)
ts2 = get_node_ts(2,run,node)


def slidingISFC(sub1,sub2,run,node,window_size):
    node_ts1 = get_node_ts(sub1,run,node)
    node_ts2 = get_node_ts(sub2,run,node)
    assert len(node_ts1) == len(node_ts2)
    
    corr = []
    # sliding window (in TRs) correlation
    for t in range(len(node_ts1) - window_size):
        # get segment
        node_ts1_seg = node_ts1[ t : t+window_size ]
        node_ts2_seg = node_ts2[ t : t+window_size ]
        # correlate segments
        # assert (np.correlate(node_ts1_seg, node_ts2_seg) 
             # == np.correlate(node_ts2_seg, node_ts1_seg))
        # collect correlation 
        
        corr.extend(np.correlate(node_ts1_seg, node_ts2_seg))

    # z = np.log((1 + r) / (1 - r)) * (np.sqrt(n - 3) / 2)
    # r-to-z transform
    n = len(corr)
    z_corr = np.log((1 + corr) / (1 - corr)) * (np.sqrt(n - 3) / 2)
    return z_corr



ts1 = slidingISFC(1,2,3,'rIPL',window_size)
plt.plot(ts1)

ts2 = slidingISFC(1,4,3,'rIPL',window_size)
plt.plot(ts2)

plt.show()


# ts3=slidingISFC(2,4,3,node,window_size)
# plt.plot(ts3)




# save results
# result_fname = "ISFC-%ss%.2i-%ss%.2i-r%.2i" % (node1, sub1, node2, sub2, run)
# result_fpath = opj(bids_dir, "deriv", "analysis_ISFC", result_fname)
# np.savetxt(result_fpath, corr)
    
