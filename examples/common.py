import sys, time
sys.path.append("..")

import pyximport
pyximport.install()

from vidcore import vg, egl, bcm

_c = egl._constants


bcm.host_init()


def create_window(width, height):
    W,H = bcm.graphics_get_display_size(0)
    print "Width, Height: %d, %d"%(W,H)
    W,H=width,height #width,height
    dst = bcm.Rect(0,0,W,H)
    src = bcm.Rect(0,0,W<<16,H<<16)
    display = egl.bcm_display_open(0)
    update = egl.bcm_update_start(0)
    element = egl.bcm_element_add(update, display, 0, dst, src)
    win = egl.NativeWindow(element, W, H)
    egl.bcm_update_submit_sync(update)
    return win
        
    
def make_egl_context(win, flags):
    api = egl._constants.EGL_OPENVG_API
    attribs = [_c.EGL_RED_SIZE,       8,
       _c.EGL_GREEN_SIZE,     8,
       _c.EGL_BLUE_SIZE,      8,
       _c.EGL_ALPHA_SIZE,     8,
       _c.EGL_DEPTH_SIZE,     _c.EGL_DONT_CARE,
       _c.EGL_STENCIL_SIZE,   _c.EGL_DONT_CARE,
       _c.EGL_SAMPLE_BUFFERS,  0,
       _c.EGL_NONE]
    
    display = egl.GetDisplay(_c.EGL_DEFAULT_DISPLAY)
    major, minor = egl.Initialise(display)
    print "EGL Version %d.%d"%(major, minor)
    egl.BindAPI(_c.EGL_OPENVG_API)
    N = egl.GetConfigs(display)
    print "There are %d configs"%N
    config = egl.ChooseConfig(display, attribs, 1)[0]
    surface = egl.CreateWindowSurface(display, config, win)
    context = egl.CreateContext(display, config, None)
    egl.MakeCurrent(display, surface, surface, context)
    return (display, surface, context)


def mainloop(display, surface, context, draw_func):
    count = 0
    start=time.time()
    try:
        while True:#for i in xrange(200):
            draw_func()
            egl.SwapBuffers(display, surface)
            count += 1
            now = time.time()
            if now-start > 2.0:
                print "FPS:", count / float(now-start)
                start=now
                count=0
    except KeyboardInterrupt:
        sys.exit(0)
