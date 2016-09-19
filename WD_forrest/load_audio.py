import os
from os.path import join as opj
import numpy as np
from mvpa2.suite import *


if 'andrebeukers' in os.getcwd().split('/'):
    print "home"
    path2_BIDSforrest = "/Users/andrebeukers/Documents/fMRI/Forrest/BIDSforrest"
elif 'srm254' in os.getcwd().split('/'):
    print "srm"
    path2_BIDSforrest = "/home/fs01/srm254/Forrest/BIDSforrest"
elif 'tmp' in os.getcwd().split('/'):
    print "temp"
    from glob import glob as glob
    path_list = glob("/tmp/*.hd-hni.cac.cornell.edu/BIDSforrest")
    assert len(path_list) == 1
    path2_BIDSforrest = path_list[0]


""" HELPER FUNCTIONS """

def parse_BIDSfname(fname_or_path):
    fname = fname_or_path.split('/')[-1]
    D = dict()
    for i in fname.split('-')[:-1]:
        j = i.split('_')
        D[j[0]] = j[1]
    D['ftype'] = fname.split('-')[-1]
    return D


""" LOADING FUNCTIONS """

# remove overlapping volumes
def rm_overlap(ds,run):

    if run == 1: ds = ds[:-4]
    elif run < 8: ds = ds[4:-4]
    else: ds = ds[4:]

    return ds

# load motion correction
def load_moco(ds,sub,ses,run):
    global path2_BIDSforrest

    mcflirt = McFlirtParams(opj(path2_BIDSforrest, "raw", "sub_%.2i" % sub,
        'sub_%.2i-ses_%s-run_%.2i-moco.txt') % (sub, ses, run))
    for param in mcflirt:
        ds.sa["mc-" + param] = mcflirt[param]
        
    return ds

# load sample attributes
def load_sa(ds,sub,run):

    chunk = 10*sub + run
    ds.sa['sub'] = sub * np.ones(ds.nsamples)
    ds.sa['run'] = run * np.ones(ds.nsamples)
    ds.sa['chunks'] =  chunk * np.ones(ds.nsamples)
    ds.a.fname = list()

    return ds


""" MAIN FUNCTION """

def load_run_ds(sub,ses,run):
    global path2_BIDSforrest

    path2_bold = opj(path2_BIDSforrest, "raw", "sub_%.2i" % sub, 
        "sub_%.2i-ses_%s-run_%.2i-bold.nii.gz" % (sub, ses, run))
    
    # load dataset
    run_ds = fmri_dataset(path2_bold)
    # load motion parameters
    run_ds = load_moco(run_ds,sub,ses,run)
    # remove overlap
    run_ds = rm_overlap(run_ds,run)
    # sample attributes
    run_ds = load_sa(run_ds,sub,run)
    

    return run_ds


""" LOOP LOAD FUNCTIONS """

# single subject multiple runs
def load_sub_ds(sub,ses,runs):

    sub_ds_list = list()
    for r in runs:
        print " run: %s" %r
        run_ds = load_run_ds(sub,ses,r)
        sub_ds_list.append(run_ds)
    sub_ds = vstack(sub_ds_list, a='uniques')
    return sub_ds

# multiple subjects multiple runs
def load_DS(subs,ses,runs):

    DS_list = list()
    for s in subs:
        print "sub: %s" %s 
        sub_ds = load_sub_ds(s,ses,runs)
        DS_list.append(sub_ds)
    DS = vstack(DS_list, a='uniques')
    return DS









