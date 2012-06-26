
import os, time
from common import vg, create_window, make_egl_context, mainloop
from vidcore.freetype import Face
from itertools import chain

convert_cmd={'MOVE_TO': vg.VGPathCommand.VG_MOVE_TO_ABS,
             'LINE_TO': vg.VGPathCommand.VG_LINE_TO_ABS,
             'CONIC_TO': vg.VGPathCommand.VG_QUAD_TO_ABS,
             'CUBIC_TO': vg.VGPathCommand.VG_CUBIC_TO_ABS}


class Text(object):
    """A higher level text object. Will migrate to Cython when I've settled on an API.
    
    The glyphs are cached in the vg.Font object until the font-size is changed (which
    effectively clears the cache).
    """
    def __init__(self, face):
        self.face = face
        self._size=None
        self.size = 12.0 #in points
        self.glyphs = set()
        self.map = {}
        self.font = vg.Font(256)
        
    @property
    def size(self):
        return self._size
        
    @size.setter
    def size(self, val):
        if val != self._size:
            self.face.set_char_size(val*64)
            self._size = val
            self.glyphs = set()
            self.map = {}
        
        
    def draw_text(self, utext):
        face = self.face
        font = self.font
        map = self.map
        glyphs = self.glyphs
        chars = set(utext).difference(glyphs)
        vg.set_fv(vg.VGParamType.VG_GLYPH_ORIGIN, [0.0,0.0])
        scale=1.0/64
        for char in chars:
            idx = face.get_char_index(ord(char))
            map[char]=idx
            face.load_glyph(idx)
            outline = face.decompose_glyph()
            cmds = [convert_cmd[item[0]] for item in outline]
            points = [tuple(chain(*item[1:])) for item in outline]
            path = vg.Path(scale=scale)
            ax,ay = face.get_advance()
            if cmds:
                path.append_data(cmds, points)
            font.set_glyph_to_path(idx, path, 0, [0,0],
                                    [ax*scale,ay*scale])
        glyphs.update(chars)
        text_idxs = [map[char] for char in utext]
        adj_x = [0]*len(text_idxs) #kerning
        adj_y = adj_x
        font.draw_glyphs(text_idxs, adj_x, adj_y, \
                    vg.VGPaintMode.VG_FILL_PATH, 0)


def draw():
    vg.clear(0,0,MAX_X, MAX_Y)
    vg.translate(150,0)
    vg.rotate(180./60)
    vg.translate(-150,0)
    txt.draw_text("Hello Raspberry Pi!")
        
if __name__=="__main__":
    WINDOW_RGB=0
    MAX_X = 620
    MAX_Y = 430
    win = create_window( MAX_X, MAX_Y )
    dpy, surf, ctx = make_egl_context(win, 0)
    
    vg.set_clear_colour(0.5,0.5,0.5,1.0)
    
    ttf_file = "/usr/share/fonts/truetype/ttf-dejavu/DejaVuSerif.ttf"
    face = Face(ttf_file)
    txt = Text(face)
    txt.size = 24 #in points (1.72 of inch)
    vg.SetParam(vg.VGParamType.VG_MATRIX_MODE,
                    vg.VGMatrixMode.VG_MATRIX_GLYPH_USER_TO_SURFACE)
    vg.load_identity()
    vg.translate(MAX_X/2-150,MAX_Y/2)
    mainloop(dpy, surf, ctx, draw)
