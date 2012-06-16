
cdef extern from "ft_wrap.h":
    ctypedef int  FT_Error
    ctypedef signed long  FT_Long
    ctypedef unsigned long  FT_ULong
    ctypedef signed int  FT_Int
    ctypedef unsigned short  FT_UShort
    ctypedef signed short  FT_Short
    ctypedef signed long  FT_Pos
    ctypedef signed long  FT_F26Dot6
    ctypedef unsigned int  FT_UInt
    ctypedef signed int  FT_Int32 ###IS THIS CORRECT???
    
    cdef struct FT_LibraryRec_:
        pass
    ctypedef FT_LibraryRec_* FT_Library
    
    cdef struct FT_Bitmap_Size_:
        FT_Short  height
        FT_Short  width
        FT_Pos    size
        FT_Pos    x_ppem
        FT_Pos    y_ppem
    ctypedef FT_Bitmap_Size_ FT_Bitmap_Size
    
    cdef struct FT_CharMapRec_:
        pass
    ctypedef FT_CharMapRec_*  FT_CharMap
    
    cdef struct FT_Outline_:
        pass
    ctypedef FT_Outline_ FT_Outline
    
    cdef struct FT_GlyphSlotRec_:
        FT_Outline outline
    ctypedef FT_GlyphSlotRec_* FT_GlyphSlot
    
    cdef struct FT_FaceRec_:
        FT_Long num_glyphs
        FT_Long num_faces
        FT_Long face_index
        FT_Long face_flags
        FT_Long style_flags
        FT_UShort units_per_EM
        FT_Int num_fixed_sizes
        FT_Bitmap_Size *available_sizes
        FT_Int num_charmaps
        FT_CharMap* charmaps
        FT_GlyphSlot glyph
    ctypedef FT_FaceRec_* FT_Face
    
    cdef struct  FT_Vector_:
        FT_Pos  x
        FT_Pos  y
    ctypedef FT_Vector_ FT_Vector
    
    ctypedef int (*FT_Outline_MoveToFunc)(FT_Vector*  to, void* user )
    ctypedef int (*FT_Outline_LineToFunc)(FT_Vector*  to, void* user )
    ctypedef int (*FT_Outline_ConicToFunc)(FT_Vector*  control,\
                             FT_Vector*  to,  void* user )
    ctypedef int (*FT_Outline_CubicToFunc)(FT_Vector*  control1,\
                    FT_Vector*  control2, FT_Vector*  to, void* user )
    
    cdef struct  FT_Outline_Funcs_:
        FT_Outline_MoveToFunc   move_to
        FT_Outline_LineToFunc   line_to
        FT_Outline_ConicToFunc  conic_to
        FT_Outline_CubicToFunc  cubic_to
        int                     shift
        FT_Pos                  delta
    ctypedef FT_Outline_Funcs_ FT_Outline_Funcs
    
    FT_Error FT_Init_FreeType(FT_Library  *alibrary)
    FT_Error FT_New_Face( FT_Library library, char* filepath, FT_Long face_index, FT_Face *face )
    FT_Error FT_Done_Face( FT_Face face )
    FT_Error FT_Set_Char_Size(FT_Face face, FT_F26Dot6 width, FT_F26Dot6 height,\
                                FT_UInt horz_res, FT_UInt vert_res)
    FT_UInt FT_Get_Char_Index(FT_Face face, FT_ULong charcode)
    FT_Error FT_Load_Glyph( FT_Face   face, FT_UInt   glyph_index, FT_Int32  load_flags )
    FT_Error FT_Outline_Decompose( FT_Outline* outline, FT_Outline_Funcs*  func_interface,\
                                        void* user )
    
cdef:
    FT_Library library
    FT_Error error


class FreeTypeError(Exception):
    pass
    
    
class LoadFlags(object):
    DEFAULT                      =0x0
    NO_SCALE                     =( 1L << 0 )
    NO_HINTING                   =( 1L << 1 )
    RENDER                       =( 1L << 2 )
    NO_BITMAP                    =( 1L << 3 )
    VERTICAL_LAYOUT              =( 1L << 4 )
    FORCE_AUTOHINT               =( 1L << 5 )
    CROP_BITMAP                  =( 1L << 6 )
    PEDANTIC                     =( 1L << 7 )
    IGNORE_GLOBAL_ADVANCE_WIDTH  =( 1L << 9 )
    NO_RECURSE                   =( 1L << 10 )
    IGNORE_TRANSFORM             =( 1L << 11 )
    MONOCHROME                   =( 1L << 12 )
    LINEAR_DESIGN                =( 1L << 13 )
    NO_AUTOHINT                  =( 1L << 15 )


error = FT_Init_FreeType( &library )
if error != 0:
    raise FreeTypeError("Failed to initialise FreeType. Code %d"%error)
    

cdef int move_to(FT_Vector* to, void* user):
    cdef list data=<list>user
    data.append(('MOVE_TO', (float(to.x), float(to.y)) ))
    
cdef int line_to(FT_Vector* to, void* user):
    cdef list data=<list>user
    data.append(('LINE_TO', (float(to.x), float(to.y))))
    
cdef int conic_to(FT_Vector* control, FT_Vector* to, void* user):
    cdef list data=<list>user
    data.append( ('CONIC_TO', (float(control.x), float(control.y)),\
                            (float(to.x), float(to.y))) )
                            
cdef int cubic_to(FT_Vector* ctrl1, FT_Vector* ctrl2, FT_Vector* to, void* user):
    cdef list data=<list>user
    data.append( ('CONIC_TO', (float(ctrl1.x), float(ctrl1.y)),\
                            (float(ctrl2.x), float(ctrl2.y)),\
                            (float(to.x), float(to.y))) )
    
cdef FT_Outline_Funcs outline_funcs

outline_funcs.move_to = move_to
outline_funcs.line_to = line_to
outline_funcs.conic_to = conic_to
outline_funcs.cubic_to = cubic_to
outline_funcs.shift = 0
outline_funcs.delta = 0
    

cdef class Face:
    cdef:
        FT_Face _face

    def __cinit__(self, char* filepath, FT_Long face_index=0):
        cdef FT_Error err
        err = FT_New_Face(library, filepath, face_index, &self._face)
        if err:
            raise FreeTypeError("Couldn't create Face object: code %d"%err)
            
    def __dealloc__(self):
        cdef FT_Error err
        err = FT_Done_Face(self._face)
        if err:
            raise FreeTypeError("Failed to dispose of face: code %d"%err)
            
    property num_glyphs:
        def __get__(self): return self._face.num_glyphs

    property face_flags:
        def __get__(self): return self._face.face_flags
        
    def set_char_size(self, FT_F26Dot6 height, FT_F26Dot6 width=0,\
                        FT_UInt horz_res=96, FT_UInt vert_res=96):
        cdef FT_Error err
        err = FT_Set_Char_Size(self._face, width, height, horz_res, vert_res)
        if err: raise FreeTypeError("Couldn't set char size: code %d"%err)

    def get_char_index(self, FT_ULong charcode):
        return FT_Get_Char_Index(self._face, charcode)

    def load_glyph(self, FT_UInt glyph_index, FT_Int32 load_flags=0):
        cdef FT_Error err
        err = FT_Load_Glyph(self._face, glyph_index, load_flags)
        if err: raise FreeTypeError("Failed to load glyph: code %d"%err)
        
    def decompose_glyph(self):
        cdef:
            list data=['foo']
            FT_Error err
            #void* ptr = &data
        err = FT_Outline_Decompose(&self._face.glyph.outline,\
                                    &outline_funcs,
                                    <void*>data)
        if err: raise FreeTypeError("Couldn't decompose glyph outline: code %d"%err)
        return data
        
