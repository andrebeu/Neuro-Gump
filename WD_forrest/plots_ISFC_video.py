import os
from os.path import join as opj
import numpy as np
import matplotlib.pyplot as plt



# # PATHS
if "andrebeukers" in os.getcwd():
    bids_dir = "/Users/andrebeukers/Documents/fMRI/Forrest/BIDSforrest"
elif "srm254" in os.getcwd():
    bids_dir = "/Users/andrebeukers/Documents/fMRI/Forrest/BIDSforrest"
elif "tmp" in os.getcwd():
    bids_dir = "/Users/andrebeukers/Documents/fMRI/Forrest/BIDSforrest"


node1 = "rPCC"
node2 = "rPCC"

def get_fpath(sub1,sub2,run,node1,node2):
    results_fpath = opj(bids_dir, "deriv", "analysis_ISFC", 
        "ISFC-%ss%.2i-%ss%.2i-r%.2i" % (node1, sub1, node2, sub2, run))
    return results_fpath



results_fpath1 = get_fpath(1,2,3,node1,node2)
ISFC_ts1 = np.genfromtxt(results_fpath1)

plt.plot(ISFC_ts1)

results_fpath2 = get_fpath(1,4,3,node1,node2)
ISFC_ts2 = np.genfromtxt(results_fpath2)

plt.plot(ISFC_ts2)

results_fpath3 = get_fpath(2,4,3,node1,node2)
ISFC_ts3 = np.genfromtxt(results_fpath3)

plt.plot(ISFC_ts3)

plt.show()

