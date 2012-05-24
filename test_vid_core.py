import pyximport
pyximport.install()

import es, vg

ctx = es.Context()

self = ctx.get_self()
print "check:", self is ctx

#es.InitContext(ctx)
ES_WINDOW_RGB=0
es.CreateWindow(ctx, "Hello Triangle", 320, 240, ES_WINDOW_RGB )

print "making path..."
path = vg.Path()

cmds = [vg.VGPathSegment.VG_LINE_TO]*3
coords = [(10.,20.), (200.,230.), (50.,23.)]
path.AppendPathData(cmds, coords)

#print "destroying path..."
#del path

def func(ctx):
    print "foo", ctx
    vg.SetClearColour(1.0,0.0,1.0,1.0)
    vg.Clear(0,0,300,200)
    path = vg.Path()
    path.AppendPathData(cmds, coords)
    path.DrawPath()
    
es.RegisterDrawFunc(ctx, func)

print "draw_func", ctx.draw_func

es.MainLoop(ctx)
print "end"



