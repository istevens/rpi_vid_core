import os
from common import vg, create_window, make_egl_context
import Image
print "START"
pth = "/usr/share/icons/hicolor/32x32/apps/midori.png"
assert os.path.exists(pth)

MAX_X = 620
MAX_Y = 430
WINDOW_RGB=0
win = create_window( MAX_X, MAX_Y )
dpy, surf, ctx = make_egl_context(win, 0)

print "limits", vg.get_i(vg.VGParamType.VG_MAX_IMAGE_WIDTH), \
        vg.get_i(vg.VGParamType.VG_MAX_IMAGE_HEIGHT)

im = Image.open(pth)
w,h = im.size
data = im.tostring()

print "Get data length", len(data), "Shape", (w,h)

vgimg = vg.Image.from_string(data, w, h)
print "made VGImage", vgimg
out = vgimg.to_string()

print "check:", out == data


