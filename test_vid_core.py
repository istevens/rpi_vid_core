import pyximport
pyximport.install()

import es

ctx = es.Context()

self = ctx.get_self()
print "check:", self is ctx

#es.InitContext(ctx)
ES_WINDOW_RGB=0
es.CreateWindow(ctx, "Hello Triangle", 320, 240, ES_WINDOW_RGB )

def func(ctx):
    print "foo", ctx
es.RegisterDrawFunc(ctx, func)

print "draw_func", ctx.draw_func

es.MainLoop(ctx)
print "end"



