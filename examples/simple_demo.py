import sys, time
from common import create_window, make_egl_context, egl
    
from vidcore import vg
    
def mainloop(display, surface, context, draw_func):
    try:
        while True:#for i in xrange(200):
            time.sleep(0.1) #so we don't spin the CPU too much
            draw_func()
            egl.SwapBuffers(display, surface)
    except KeyboardInterupt:
        sys.exit(0)
        
        
if __name__=="__main__":
    WINDOW_RGB=0
    win = create_window( 620, 430 )
    dpy, surf, ctx = make_egl_context(win, 0)
    
    path = vg.Path(segmentCapacityHint=4,
                    coordCapacityHint=3,
                    capabilities=vg.VGPathCapabilities.VG_PATH_CAPABILITY_ALL)
    cmds = [vg.VGPathSegment.VG_LINE_TO]*3
    coords = [(10.,20.), (200.,230.), (50.,23.)]
    path.append_data(cmds, coords)
    
    pt = vg.Paint()
    color = 255
    color = color << 8 | 255
    color = color << 8 | 255
    color = color << 8 | 255
    pt.set_color(color)
    vg.set_paint(pt, vg.VGPaintMode.VG_FILL_PATH)
    
    vg.SetParam(vg.VGParamType.VG_STROKE_LINE_WIDTH, 5.0)
    
    vg.scale(1.0,1.0)

    def draw():
        #print "beging drawing ...",
        vg.set_clear_colour(1.0,0.0,1.0,1.0)
        vg.clear(0,0,300,200)
        path.draw(vg.VGPaintMode.VG_STROKE_PATH|vg.VGPaintMode.VG_FILL_PATH)
        #print "...end drawing"
        
    mainloop(dpy, surf, ctx, draw)
    
    
    
    
