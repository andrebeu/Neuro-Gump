import os
from os.path import join as opj
import numpy as np

sub1=3
sub2=4


DMNnodes = ["PCC","IPL"]
AUDnodes = ["A1","PCG"]

node1 = "rPCC"
node2 = "rIPL"

# load from .1D to np array
fpath1="/Users/andrebeukers/Documents/fMRI/Forrest/BIDSforrest/deriv/sub_04/ses_video/sub_04-run_03-PCC_ts.1D"
fpath2="/Users/andrebeukers/Documents/fMRI/Forrest/BIDSforrest/deriv/sub_04/ses_video/sub_04-run_03-PCC_ts.1D"
node1_ts = np.genfromtxt(fpath1, delimiter=' ')
node2_ts = np.genfromtxt(fpath2, delimiter=' ')

# sliding window correlation
window_size = 40
corr=[]
for t in range(len(node1_ts) - window_size):
    node1_ts_seg = node1_ts[ t:t+window_size ]
    node2_ts_seg = node2_ts[ t:t+window_size ]
    corr_seg = np.correlate(node1_ts_seg, node2_ts_seg)
    corr.extend(corr_seg)


    

