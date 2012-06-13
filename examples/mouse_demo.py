### copyright Cambridge and East Anglian Python Userss Group 2012 ###
### Dojo meeting 12th June 2012 ###

import sys, time
from common import create_window, make_egl_context
    
from vidcore import vg, egl

XSIGN = 1<<4
YSIGN = 1<<5

MAX_X = 620
MAX_Y = 430

MIN_X = 0
MIN_Y = 0

BLACK = 0x000000ff
WHITE = 0xffffffff
RED   = 0xff0000ff
GRN   = 0x00ff00ff
BLU   = 0x0000ffff

GREEN = GRN
BLUE = BLU

def paintify(color):
    p = vg.Paint()
    p.set_color(color)
    return p

def set_fill_paint(paint):
    vg.set_paint(paint, vg.VGPaintMode.VG_FILL_PATH)

def set_stroke_paint(paint):
    vg.set_paint(paint, vg.VGPaintMode.VG_STROKE_PATH)

def set_fill_col(color):
    set_fill_paint(paintify(color))

def set_stroke_col(color):
    set_stroke_paint(paintify(color))

def set_stroke_width(width):
    vg.SetParam(vg.VGParamType.VG_STROKE_LINE_WIDTH, float(width))

def pathify(coords):
    path = vg.Path(segmentCapacityHint=4,
                    coordCapacityHint=3,
                    capabilities=vg.VGPathCapabilities.VG_PATH_CAPABILITY_ALL)

    cmds = [vg.VGPathSegment.VG_MOVE_TO] + [vg.VGPathSegment.VG_LINE_TO]*(len(coords)-1)

    path.append_data(cmds, coords)
    return path

def mainloop(display, surface, context, draw_func):
    try:
        
        fd = open('/dev/input/mouse0','r')
        
        x = MAX_X/2
        y = MAX_Y/2
        sofar = [(x,y)]
            
        
        while True:#for i in xrange(200):
            
            buttons,dx,dy=map(ord,fd.read(3))
            #print("dx: %s dy: %s buttons: %s") %(dx, dy, buttons)
            if buttons&XSIGN:
                dx-=256
            if buttons&YSIGN:
                dy-=256
            #print ("dx: %s, dy: %s") %(dx, dy)
            
            x += dx
            y += dy
            
            if x < MIN_X:
                x = MIN_X
            if x > MAX_X:
                x = MAX_X
                
            if y < MIN_Y:
                y = MIN_Y
            if y > MAX_Y:
                y = MAX_Y
            
            #rint("value from center: x: %s, y: %s") %(x,y)
            
            draw_func(x, y, sofar)
            egl.SwapBuffers(display, surface)
            
    except KeyboardInterrupt:
        sys.exit(0)
        
def draw(x, y, sofar):
    vg.set_clear_colour(1.0,0.0,1.0,1.0)
    #vg.clear(0,0,x+1,y+1)
    if len(sofar) > 100:
        del sofar[:-100]
    sofar.append((x,y))
    path = pathify(sofar)
    print sofar
    set_fill_col(RED)
    set_stroke_col(BLACK)
    set_stroke_width(5.0)
    path.draw(vg.VGPaintMode.VG_STROKE_PATH|vg.VGPaintMode.VG_FILL_PATH)
        
if __name__=="__main__":
    WINDOW_RGB=0
    win = create_window( MAX_X, MAX_Y )
    dpy, surf, ctx = make_egl_context(win, 0)
        
    mainloop(dpy, surf, ctx, draw)
