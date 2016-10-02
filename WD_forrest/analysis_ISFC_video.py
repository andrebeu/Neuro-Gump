import os
from os.path import join as opj
import matplotlib.pyplot as plt
from scipy.stats import zscore as sczscore
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


def get_node_ts(sub,run,node):
    global bids_dir
    deriv_dir = opj("/Users/andrebeukers/Documents/fMRI/Forrest/from_serv/deriv", "sub_%.2i" % sub, "ses_video")
    node_fpath = opj(deriv_dir, "nodes", "sub_%.2i-run_%.2i-%s_ts.1D" % (sub, run, node))
    # print node_fpath
    node_ts = pd.read_csv(node_fpath, delimiter=' ', header=None)
    z_node_ts = sczscore(node_ts.iloc[:,0].values)
    return z_node_ts

def slidingISFC(sub1,sub2,run,node1,node2,window_size):
    node_ts1 = get_node_ts(sub1,run,node1)
    node_ts2 = get_node_ts(sub2,run,node2)
    assert len(node_ts1) == len(node_ts2)
    
    corr = []
    # sliding window (in TRs) correlation
    for t in range(len(node_ts1) - window_size):
        # get segment
        node_ts1_seg = node_ts1[ t : t+window_size ]
        node_ts2_seg = node_ts2[ t : t+window_size ]
        # correlate segments
        # assert (np.correlate(node_ts1_seg, node_ts2_seg) 
        #      == np.correlate(node_ts2_seg, node_ts1_seg))
        # collect correlation 
        r = np.corrcoef(node_ts1_seg, node_ts2_seg)[0][1]
        # print r
        corr.append(r)

    # r-to-z transform
    n = len(corr)
    z_corr = np.arctanh(corr) / (1 / np.sqrt(n - 3))

    return z_corr

run = 3
subs = [1,2,3,4,5]
nodes = ['rA1','lA1','rIPL','lIPL','rPCC','lPCC','rPCG','lPCG','rPFC','lPFC']
path2_deriv = "/Users/andrebeukers/Documents/fMRI/Forrest/from_serv/deriv"
window_size = 50

for sub1 in subs:
    for sub2 in subs:
        for node1 in nodes:
            for node2 in nodes:
                if not ((sub1 == sub2) & (node1 == node2)):
                    if sub1 == sub2: analysis = 'FC'
                    else: analysis = 'ISFC'
                    ISFCresult = slidingISFC(sub1,sub2,3,node1,node2,50)
                    result_fname = "%s-%ss%.2i-%ss%.2i-r%.2i" % (analysis, node1, sub1, node2, sub2, 3)
                    result_fpath = opj(path2_deriv, "analysis_ISFC", result_fname)
                    np.savetxt(result_fpath, ISFCresult)



for s in itertools.combinations(subs,2):
    sub1 = s[0]
    sub2 = s[1]
    for node1 in nodes:
        for node2 in nodes:

            sub1
            # ISFCresult = slidingISFC(sub1,sub2,run,node1,node2,window_size)
            result_fpath = opj(path2_deriv, "analysis_ISFC", result_fname)
            np.savetxt(result_fname, ISFCresult)

         


for s1 in subs:
    for s2 in subs:
        sub1 = s1
        sub2 = s2
        subs.remove(s1)
        for node1 in nodes:
            for node2 in nodes:

                ISFCresult = slidingISFC(sub1,sub2,3,node1,node2,50)

                # save results
                result_fname = "ISFC-%ss%.2i-%ss%.2i-r%.2i" % (node1, sub1, node2, sub2, 3)
                result_fpath = opj(path2_deriv, "analysis_ISFC", result_fname)
                np.savetxt(result_fname, ISFCresult)
    
