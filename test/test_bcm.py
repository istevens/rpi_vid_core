import pyximport
pyximport.install()

import bcm

bcm.host_init()

w,h = bcm.graphics_get_display_size(0)

dst = bcm.Rect(0,0,w,h)
src = bcm.Rect(0,0,w<<16,h<<16)

print dst.x, dst.y, dst.width, dst.height
print src.x, src.y, src.width, src.height

display = bcm.display_open( 0 )
update = bcm.update_start( 0 )
elem = bcm.element_add(update, display,
                        0, #layer
                        dst,src)
bcm.update_submit_sync(update)

print display
print update
print elem

print "END"
