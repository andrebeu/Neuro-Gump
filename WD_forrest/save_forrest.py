import os
from os.path import join as opj
import numpy as np
import pandas as pd
import h5py
from datetime import datetime


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

""" 
Do I want to just throw everything in deriv folder
or have one sub folder for each dataset (where I 
keep the ds, doc, and figures)?

"""


# extracts and formats DS.a.mapper for doc
def get_mapper_info(DS):
    mapper_list = DS.a.mapper.__str__().translate(None,' <>').replace(':','_').split('-')
    unwanted = ['Flatten','Chain','Chain_Flatten']
    for i in unwanted:
        if i in mapper_list:
            mapper_list.pop(mapper_list.index(i))
    mapper_info = '-'.join(mapper_list)
    return mapper_info

# fname components: time stamp, no_sub, no_runs
def assign_fname(DS):
    DS_id = "%s%s%s%s" % datetime.timetuple(datetime.now())[2:6]
    num_subjects = len(np.unique(DS.sa.sub))
    num_runs = len(np.unique(DS.sa.run))
    num_subjects = num_runs = 0
    mapper_info = get_mapper_info(DS)
    # new fname
    print "Giving DS an fname attribute"
    fname = "%.2isubs-%.2iruns-id%s" \
          % (num_subjects,num_runs,DS_id)

    # document(DS,{"num_subjects":num_subjects, "num_runs",num_runs})
    return fname


# returns fname for saving DS and doc
def get_fname(DS):
    if DS.a.has_key("fname"):
        fname = DS.a["fname"].value
    elif not DS.a.has_key("fname"):
        fname = assign_fname(DS)
        DS.a["fname"] = fname
    return fname

def get_path2_doc(DS):
    global path2_BIDSforrest
    # assemble path2_doc
    fname_doc = get_fname(DS)+"-doc.csv"
    path2_doc = opj(path2_BIDSforrest,"deriv",fname_doc)
    # make doc file if d/n exist
    if not os.path.isfile(path2_doc): 
        with open(path2_doc, 'w') as f:
            pass

    return path2_doc

# appends info (dict) to DS's doc
def document(DS, doc_2append):
    doc_2append[' '] = ' '
    path2_doc = get_path2_doc(DS)

    # getting errors depending on dtypes in dict
    try: 
        df = pd.DataFrame.from_dict(data=doc_2append).transpose()
    except: 
        df = pd.DataFrame.from_dict(data=doc_2append,orient='index')

    df.to_csv(path2_doc, mode='a', header=False, index='index')

# save DS as hdf5 and doc as txt
def save_DS(DS,name=''): 
    try: 
        fname = get_fname(DS) + name
        document(DS,{'mapper':get_mapper_info(DS)})
    except: fname = name
    DS_fpath = opj(path2_BIDSforrest, 'deriv', fname+'-ds.hdf5')
    DS.save(DS_fpath, compression = 9)

    




# h5save(path2save, DS, compression = 9)
# h5load(path2load)


# def check_fname_exists(fname):
#     # checks the existance of an fname in deriv folder
#     fpath = opj(path2_BIDSforrest,'deriv',fname)
#     fpath_ds = fpath + '-ds.hdf5'
#     fpath_doc = fpath + '-doc.csv'

#     if os.path.isfile(fname_ds) | os.path.isfile(fpath_doc):
#         return True
#     else: 
#         return False
