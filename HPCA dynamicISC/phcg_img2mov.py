import sys
from os.path import join as opj
from glob import glob as glob
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import matplotlib.image as mpimg

try: sys.argv[1]; sub_num = int(sys.argv[1])
except: sub_num = 5

plane = "axial"

anim_dir = "/Users/andrebeukers/Documents/fMRI/Forrest/" \
            + "BIDSforrest/deriv/slideISC/sub_%.2i/anim" % sub_num

# make figures for animation
def get_img(x):
    global sub_num, anim_dir
    
    img_file = opj(anim_dir, 
        "sub_%.2i-run_03-roi_rphcg-slideISC_avg_%s-%.3i.png" % (sub_num,plane[:3],x))
    img_array = mpimg.imread(img_file)
    
    return img_array

# initialize figure
fig, ax = plt.subplots(figsize=(80,50))
img = plt.imshow(get_img(1), animated=True)
plt.axis('off')
fig.tight_layout(pad=0,h_pad=0,w_pad=0)


x = 0
# make animation
def updatefig(*args):
    global x
    x += 1
    img.set_array(get_img(x))
    return img,

# number of frames
f = len(glob(opj(anim_dir,"*png"))) - 50
f = 201
# make and save animation
ani = animation.FuncAnimation(fig, updatefig, frames=f, interval=200, blit=True)
ani.save(opj(anim_dir,'sub-%.2i_%s_dynamicISC.mp4' % (sub_num,plane)), bitrate=-1)
plt.close('all')