import os
from common import vg, create_window, make_egl_context, mainloop
import Image
print "START"
pth = "/usr/share/icons/hicolor/32x32/apps/midori.png"
assert os.path.exists(pth)
import numpy

MAX_X = 620
MAX_Y = 430
WINDOW_RGB=0
win = create_window( MAX_X, MAX_Y )
dpy, surf, ctx = make_egl_context(win, 0)

print "limits", vg.get_i(vg.VGParamType.VG_MAX_IMAGE_WIDTH), \
        vg.get_i(vg.VGParamType.VG_MAX_IMAGE_HEIGHT)

im = Image.open(pth)
print "bands", im.getbands()
w,h = im.size
data = im.tostring()

ar = numpy.fromstring(data, dtype=numpy.uint32).reshape(w,h)
print ar.flags
ar=numpy.flipud(ar)

#ar[:,:,0] = 100
#ar[:,:,1] = 255

data = ar.tostring()

print "Get data length", len(data), "Shape", (w,h)

vgimg = vg.Image.from_string(data, w, h)
print "made VGImage", vgimg
out = vgimg.to_string()

print "check:", out == data

def draw():
    vg.SetParam(vg.VGParamType.VG_MATRIX_MODE,
                vg.VGMatrixMode.VG_MATRIX_IMAGE_USER_TO_SURFACE)
    vg.load_identity()
    vg.clear(0,0,MAX_X, MAX_Y)
    vg.scale(4,4)
    vg.translate(MAX_X/8, MAX_Y/8)
    vgimg.draw()
        
if __name__=="__main__":
    WINDOW_RGB=0
    win = create_window( MAX_X, MAX_Y )
    dpy, surf, ctx = make_egl_context(win, 0)
    
    vg.set_clear_colour(0.5,0.5,0.5,1.0)
    
    vgimg = vg.Image.from_string(data, w, h, format=vg.VGImageFormat.VG_lABGR_8888)
    print "format:", vgimg.format
    print "size:", vgimg.size
    mainloop(dpy, surf, ctx, draw)
