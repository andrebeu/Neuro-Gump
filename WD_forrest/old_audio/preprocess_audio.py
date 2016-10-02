from scipy import signal
import numpy as np
import mvpa2.suite as mvpa

import save_forrest

# linear detrend (ord=1), remove motion (in place)
# each subj,run combination treated separately 
def moco_detrend(DS):
    order = 1
    reg = [sa for sa in DS.sa.keys() if "mc-" in sa]

    # mvpa.poly_detrend(DS, chunks_attr='chunks',
    #     polyord=order, opt_regs=reg)

    for chunk in np.unique(DS.sa.chunks):
        print chunk
        mvpa.poly_detrend(DS[DS.sa.chunks==chunk], 
            polyord=order, opt_regs=reg)

    save_forrest.document(DS, {"detrend_order": order, "motion_detrend": "true"})
    return DS


def get_filt_params(DS):

    # filter parameters
    TR = 2; nf = 0.5/TR
    lopas = 150.; hipas = 9.
    crit_freq = [(1/lopas)/nf, (1/hipas)/nf]

    # estimate filter polynomial parameters
    n, d = signal.butter(5, crit_freq, btype='band')   

    save_forrest.document(DS, {"fliter_lowpass": lopas, 
        "fliter_highpass": hipas, "fliter_crit_frequency": crit_freq})

    return {"num": n, "den": d}


# signal.filtfilt:
#  applies a filter twice, once forward once backward,
#  the resulting filter has linear phase"

def band_filter(DS):

    # get filter parameters
    params = get_filt_params(DS)
    n = params['num']; d = params['den']
    # filter each voxel's time series
    fltr_output = [signal.filtfilt(n, d, vxl) for vxl in DS.samples.T]
    # load samples back to DS
    DS.samples = np.array(fltr_output).T

    return DS

# performance note on loops
"""
    A LOT SLOWER: 
    fltr_output = np.array([])
    for vxl in DS.samples.T:
        fltrd_vxl = signal.filtfilt(n, d, vxl)
        fltr_output = np.append(fltr_output, fltrd_vxl)
"""


def full(DS):

    # convert raw samples to float32
    DS.samples = DS.samples.astype('float32')
    
    print "MOTION CORRECT & LINEAR DETREND"
    moco_detrend(DS)
    print "done"
    
    # zscore (in place)
    mvpa.zscore(DS)
    save_forrest.document(DS, {"zscore": " voxelwise, not chunked "})
    
    print "BAND FILTER"
    DS = band_filter(DS)
    print "done"
    
    # convert results of filter to float32
    DS.samples = DS.samples.astype('float32')

    return DS


