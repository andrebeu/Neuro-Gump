import os
from os.path import join as opj
import matplotlib.pyplot as plt
import itertools
import numpy as np
from glob import glob

results_dir = "/Users/andrebeukers/Documents/fMRI/Forrest/from_serv/deriv/analysis_ISFC"
subs = [1,2,3,4,5]
nodes = ['rA1','lA1','rIPL','lIPL','rPCC','lPCC','rPCG','lPCG']

# using matplotlib ineractively
# %pylab

def get_leg(path):
    fname = path.split('/')[-1].split('-')

    n1 = fname[1].split('s')[0]
    s1 = fname[1].split('s')[1]
    n2 = fname[2].split('s')[0]
    s2 = fname[2].split('s')[1]

    leg = "%s %s vs %s %s" % (n1,s1,s2,n2)
    return leg


def get_ts(paths):
    print "call"
    # single path
    if (type(paths) == str):
        print "get str"
        return np.genfromtxt(paths)

    # input: list of paths, output: 2D array
    elif len(paths) > 1:
        print 'get list'
        ts = np.zeros((1,383))
        for p in paths:
            temp_ts = np.genfromtxt(p)
            ts = np.vstack((ts,temp_ts))
        ts = np.delete(ts,(0),axis=0)
        return ts


def plot_ts(paths):
    plt.figure(figsize=(15,5))

    if type(paths) == str:
        print "plot str"
        f = plt.plot(get_ts(paths), label=get_leg(paths))
        plt.legend(handles = f)
        return  

    elif type(paths) == list:
        print "list"
        # H = list()
        for p in range(len(paths)):
            print " loop ", p
            path = paths[p]
            f = plt.plot(get_ts(path), label=get_leg(path))
            plt.legend()
        return
     

    else:
        print "either list of multiple paths or str"



def get_paths(s1="*",s2="*",n1="*",n2="*",analysis='ISFC'):
    results_dir = "/Users/andrebeukers/Documents/fMRI/"+\
        "Forrest/from_serv/deriv/analysis_ISFC"
    if type(s1) == int: s1 = "%.2i" % s1
    if type(s2) == int: s2 = "%.2i" % s2
    path = opj(results_dir, '%s-%ss%s-%ss%s*' % (analysis,n1,s1,n2,s2))
    path_list = glob(path)
    print path_list
    return path_list



## PLOTS ##

# each P's lPCC with everyone elses lPFC
colors = {1:'green',2:'yellow',3:'blue',4:'purple',5:'red'}
plt.figure(figsize=(15,5))
for s in [2,4]:
    n1='lPFC'; n2='lPFC'
    paths = get_paths(s1=s,n1=n1,n2=n2)
    mean_ts = np.mean(get_ts(paths).transpose(),axis=1)
    sig_ts = np.std(get_ts(paths).transpose(),axis=1)
    plt.fill_between(range(len(mean_ts)), mean_ts+sig_ts, 
        mean_ts-sig_ts, color=colors[s], alpha=0.2)
    plt.plot(mean_ts, label="sub %s" % s, linewidth=2, color=colors[s])
    plt.title('subject %s vs avg %s' % (n1,n2)); 
    plt.legend()
    # plt.axis([0,380,])
    plt.axhline(0,color='black',linewidth=0.1)

# dyads
colors = {1:'green',2:'red'}
for n1,n2 in itertools.permutations(['lPFC','lPCC']):   
    plt.figure(figsize=(15,5))
    for s1,s2 in itertools.permutations([1,2]):
        path = get_paths(s1=s1,s2=s2,n1=n1,n2=n2)[0]
        sub_ts = get_ts(path)
        plt.plot(sub_ts, label="sub %.2i %s, sub %.2i %s" % (s1,n1,s2,n2), 
            linewidth=2, color = colors[s1])
        plt.title("Dyad"); plt.legend()





