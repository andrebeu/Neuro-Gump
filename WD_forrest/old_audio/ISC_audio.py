"""
Takes path to hdf5 timesegmented dataset
Performs ISC
"""


import mvpa2.suite as mvpa
import numpy as np
import scipy.spatial.distance as spatial_dist
import save_forrest


# path2_ds="/Users/andrebeukers/Documents/fMRI/Forrest/from_serv/02subs-01runs-id1393448-ds.hdf5"
# path2_ds="/home/fs01/srm254/Forrest/BIDSforrest/deriv/02subs-01runs-id1393448-ds.hdf5"

sub1=1
sub2=2


# load
DS = mvpa.h5load(path2_ds)

# why reverse map? 
# rds1 = ds1.mapper.reverse1(ds1)
# rds2 = ds2.mapper.reverse1(ds2)

## orig
# dsfile = '_z'+str(zsc)+'_'+str(samples_size)+'_'+align
# ## Load dataset of two subjects and reorganise for univariate analysis
# evds1 = mvpa.h5load(os.path.join('dataset',subj1+dsfile+'.hdf5'))
# evds1 = evds1.mapper.reverse(evds1)
# evds2 = mvpa.h5load(os.path.join('dataset',subj2+dsfile+'.hdf5'))
# evds2 = evds1.mapper.reverse(evds2)
# evds = mvpa.vstack([evds1,evds2])
# del evds1, evds2

# # individual subjects
# ds1 = DS[DS.sa.sub[:,0]==sub1]
# ds2 = DS[DS.sa.sub[:,0]==sub2]
# # NB evds1.samples == DS.samples
# evds = mvpa.vstack([ds1,ds2])

## By defining a class, able to call searchlight
class Corr_class(mvpa.Measure):
    is_trained = True

    def __init__(self, subj1_samples,subj2_samples, **kwargs):
        mvpa.Measure.__init__(self, **kwargs)
        self._subj1 = subj1_samples
        self._subj2 = subj2_samples

    # correlation measure
    def _call(self):
        # samples_sub1 = evds[ evds.sa.subj==self._subj1 ].samples
        # samples_sub2 = evds[ evds.sa.subj==self._subj2 ].samples
        samples_tup = (self._subj1, self._subj2)
        corr = spatial_dist.pdist( np.hstack(samples_tup).T, 'correlation' )
        correlation_distance = 1 - corr
        return mvpa.Dataset( np.array(correlation_distance)[np.newaxis] )


def corr_fun(sub1_samples,sub2_samples):
    samples_tup = (sub1_samples,sub2_samples)
    corr = spatial_dist.pdist( np.hstack(samples_tup).T, 'correlation' )
    correlation_distance = 1 - corr
    return correlation_distance

samples_ds1 = DS[DS.sa.sub[:,0]==sub1].samples
samples_ds2 = DS[DS.sa.sub[:,0]==sub2].samples
result = corr_fun(samples_ds1,samples_ds2)

minis_ds1 = samples_ds1[50:60,100000:101000]
minis_ds2 = samples_ds2[50:60,100000:101000]
result = corr_fun(minis_ds1,minis_ds2)

rDS = mvpa.Dataset(result)
save_forrest.save_DS(rDS, 'corr')

## Instead of defining new class, use builtin RSA
# samples_ds1 = DS[DS.sa.sub[:,0]==sub1].samples
# samples_ds2 = DS[DS.sa.sub[:,0]==sub2].samples
# samples_tup = (samples_ds1,samples_ds2)

# corr = spatial_dist.pdist( np.hstack(samples_tup).T, 'correlation' )
# corr_distance = 1 - corr
