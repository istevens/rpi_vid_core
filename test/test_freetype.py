
import pyximport
pyximport.install()
import sys
sys.path.append('..')

from vidcore import freetype as ft

ttf_file = "/usr/share/fonts/truetype/ttf-dejavu/DejaVuSans.ttf"


face = ft.Face(ttf_file)

print face
print face.num_glyphs

face.set_char_size(12*64)

index = face.get_char_index(ord('g'))
print "index=", index, "for", ord('g')
face.load_glyph(index)

data = face.decompose_glyph()
print data

del face

print "END"
