import numpy as np
from mvpa2.suite import extract_boxcar_event_samples, vstack

import save_forrest

"""
input: DS (vairbale num of subjs,ses,runs)
output: eventDS: able to match corresponding segments in same run diff subjects

pass subrunDS, loop through DS making event_subrunDS, 
event_DS=vstack(list_event_subrunDS)
"""

## returns dictlist passed to make eds
def get_event_dictlist(DS,sub,run):

    TR = 2; seg_length = 12 # [in sec]
    # num of TRs(samples) per segment
    dur = seg_length / TR 

    # array with TR_num at which segment began
    segment_onsets = np.arange(0, DS.nsamples, seg_length/TR)[:-1]
    # why pop the last segment?

    # # Event related dataset
    event_dictlist = []
    for seg_on in segment_onsets:
        ev = {}
        ev['onset'] = seg_on
        ev['duration'] = dur # event_DS.fa.event_offsetidx
        ev['targets'] = seg_on * TR # does this have any meaning?
        event_dictlist.append(ev)

    return event_dictlist


## make event related dataset for subrun
def make_event_subrunDS(DS,sub,run):

    # subject DS and events
    subrunDS = DS[(DS.sa.run == run) & (DS.sa.sub == sub)]
    # print sub,run

    event_dictlist = get_event_dictlist(subrunDS,sub,run)
    # print event_dictlist

    # consecutive samples in same event are concatenated (see DS.shape)
    event_subrunDS = extract_boxcar_event_samples(subrunDS,
        events = event_dictlist)

    # first sample of the segment
    event_subrunDS.fa['first_idx'] = (event_subrunDS.fa.event_offsetidx == 0)

    return event_subrunDS

# # loops through subjects and runs
def make_event_DS(DS, ass1=True):
    """ ass1: same runs in every subject 
        if ass1 list comprehension loop speeds computation """

    subs = np.unique(DS.sa.sub).astype(int)
    if ass1:
        print 'assuming every subject has same runs'
        
        runs = np.unique(DS.sa.run).astype(int)

        # list loop for improved performance
        eventDS_list = [make_event_subrunDS(DS,sub,run)\
            for sub in subs for run in runs]

    elif not ass1:
        print 'NOT assuming every subject has same runs'

        eventDS_list = []
        for sub in subs:
            # runs of current sub
            runs = np.unique(DS.sa.run[DS.sa.sub==sub]).astype(int)
            for run in runs:
                # make eDS and append to list
                event_subrunDS = make_event_subrunDS(DS,sub,run)
                eventDS_list.append(event_subrunDS)

    eventDS = vstack(eventDS_list, a=0)

    save_forrest.document(DS,{'event_related':'True'})
    return eventDS








