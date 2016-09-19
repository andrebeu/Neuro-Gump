import os

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
    assert len(path2_BIDSforrest) == 1
    path2_BIDSforrest = path_list[0]

