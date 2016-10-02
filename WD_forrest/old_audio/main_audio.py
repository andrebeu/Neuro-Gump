import os
from os.path import join as opj

## MAC OR SERV ## 
if 'andrebeukers' in os.getcwd().split('/'):
    path2_maindir = "/Users/andrebeukers/Documents/fMRI/Forrest"
elif 'srm254' in os.getcwd().split('/'):
    path2_maindir = "/home/fs01/srm254/Forrest"
elif 'tmp' in os.getcwd().split('/'):
    print "temp"
    from glob import glob as glob
    path_list = glob("/tmp/*.hd-hni.cac.cornell.edu")
    assert len(path_list) == 1
    path2_maindir = path_list[0]


## PATHS ##
path2_forrestBIDS = opj(path2_maindir, "BIDSforrest")
path2_WD = opj(path2_maindir, "WD_forrest")
os.chdir(path2_WD)

## LOAD WD ## 
import load_forrest; reload(load_forrest)
import preprocess_forrest; reload(preprocess_forrest)
import time_segments_forrest; reload(time_segments_forrest)
from save_forrest import save_DS


"""
GOAL 2 runs from 2 subjects
sub 1,2 run 3,4
"""

subs = [1,2]
ses = "audio"
runs = [3]

# Load, preprocess, segment
DS = load_forrest.load_DS(subs,ses,runs)
DS = preprocess_forrest.full(DS)
save_DS(DS,"preprocessed")
DS = time_segments_forrest.make_event_DS(DS, ass1=True)
save_DS(DS,"event")


## Consistency
import mvpa2.suite as mvpa
import numpy as np
import scipy.spatial.distance as spatial_dist

def corr_fun(sub1_samples,sub2_samples):
    samples_tup = (sub1_samples,sub2_samples)
    corr = spatial_dist.pdist( np.hstack(samples_tup).T, 'correlation' )
    correlation_distance = 1 - corr
    return mvpa.Dataset(correlation_distance)

sub1=1
sub2=2
samples_ds1 = DS[DS.sa.sub[:,0]==sub1].samples
samples_ds2 = DS[DS.sa.sub[:,0]==sub2].samples
result = corr_fun(samples_ds1,samples_ds2)
save_DS(result,'corr')


