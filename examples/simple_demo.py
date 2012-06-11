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
    attribs = [_c.EGL_RED_SIZE,       5,
       _c.EGL_GREEN_SIZE,     6,
       _c.EGL_BLUE_SIZE,      5,
       _c.EGL_ALPHA_SIZE,     _c.EGL_DONT_CARE,
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
    try:
        for i in xrange(20):
            time.sleep(0.1) #so we don't spin the CPU too much
            draw_func()
            egl.SwapBuffers(display, surface)
    except KeyboardInterupt:
        sys.exit(0)
        
        
if __name__=="__main__":
    WINDOW_RGB=0
    win = create_window( 620, 430 )
    dpy, surf, ctx = make_egl_context(win, 0)

    def draw():
        print "beging drawing ...",
        vg.set_clear_colour(1.0,0.0,1.0,1.0)
        vg.clear(0,0,300,200)
        print "...end drawing"
        
    mainloop(dpy, surf, ctx, draw)
    
    
    
    
