
import pyximport
pyximport.install()

import time
import vg, egl, bcm
import egl._constants as _c


bcm.host_init()


def create_window(title, width, height, flags, api ):
    W,H = bcm.graphics_get_display_size(0)
    W,H=width,height
    dst = bcm.Rect(0,0,W,H)
    src = bcm.Rect(0,0,W<<16,H<<16)
    display = bcm.display_open(0)
    update = bcm.update_start(0)
    element = bcm.element_add(update, display, 0, dst, src)
    win = egl.NativeWindow(element, W, H)
    update_submit_sync(update)
    return win
        
    
def make_egl_context(win, flags):
    api = egl._constants.EGL_OPENVG_API
    attribs = [_c.EGL_RED_SIZE,       5,
       _c.EGL_GREEN_SIZE,     6,
       _c.EGL_BLUE_SIZE,      5,
       _c.EGL_ALPHA_SIZE,     8 if (flags & _c.ES_WINDOW_ALPHA) else _c.EGL_DONT_CARE,
       _c.EGL_DEPTH_SIZE,     8 if (flags & _c.ES_WINDOW_DEPTH) else _c.EGL_DONT_CARE,
       _c.EGL_STENCIL_SIZE,   8 if (flags & _c.ES_WINDOW_STENCIL) else _c.EGL_DONT_CARE,
       _c.EGL_SAMPLE_BUFFERS, 1 if (flags & _c.ES_WINDOW_MULTISAMPLE) else 0,
       _c.EGL_NONE]
    
    display = egl.GetDisplay(_c.EGL_DEFAULT_DISPLAY)
    major, minor = egl.Initialize(display)
    print "EGL Version %d.%d"%(major, minor)
    egl.BindAPI(_c.EGL_OPENVG_API)
    N = egl.GetConfigs(display)
    print "There are %d configs"%N
    config = egl.ChooseConfig(display, attribs, 1)[0]
    surface = egl.CreateWindowSurface(display, config, win, None)
    context = egl.CreateContext(display, config, None, None)
    egl.MakeCurrent(display, surface, surface, context)
    return (display, surface, context)
    
    
def mainloop(display, surface, draw_func):
    while True:
        time.sleep(0.1) #so we don't spin the CPU too much
        draw_func()
        egl.SwapBuffers(display, surface)
        
        
if __name__=="__main__":
    WINDOW_RGB=0
    win = CreateWindow("Hello Triangle", 320, 240, WINDOW_RGB, egl._constants.EGL_OPENVG_API ):
    dpy, surf, ctx = make_egl_context(win, 0)
    
    def draw():
        vg.SetClearColour(1.0,0.0,1.0,1.0)
        vg.Clear(0,0,300,200)
        
    mainloop(dpy, surf, draw)
    
    
    
    
