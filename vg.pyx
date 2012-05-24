
from libc.stdlib cimport malloc, free

cdef extern from "/opt/vc/include/VG/openvg.h":
    ctypedef float          VGfloat
    ctypedef signed char    VGbyte
    ctypedef unsigned char  VGubyte
    ctypedef signed short   VGshort
    ctypedef signed int     VGint
    ctypedef unsigned int   VGuint
    ctypedef unsigned int   VGbitfield
    
    ctypedef VGuint VGHandle
    ctypedef VGHandle VGPath
    ctypedef VGHandle VGImage
    ctypedef VGHandle VGMaskLayer
    ctypedef VGHandle VGFont
    ctypedef VGHandle VGPaint
    
    enum:
        VG_MAX_ENUM = 0x7FFFFFFF
        VG_MAXINT = 0x7FFFFFFF
        VG_MAXSHORT = 0x7FFF
        VG_PATH_FORMAT_STANDARD = 0
        
    enum VGboolean:
        VG_FALSE = 0
        VG_TRUE = 1
        VG_BOOLEAN_FORCE_SIZE  = VG_MAX_ENUM
        
    enum VGPaintMode:
        VG_STROKE_PATH                              = (1 << 0)
        VG_FILL_PATH                                = (1 << 1)
        VG_PAINT_MODE_FORCE_SIZE                    = VG_MAX_ENUM
    
    enum VGPathDatatype:
        VG_PATH_DATATYPE_S_8 = 0
        VG_PATH_DATATYPE_S_16                       =  1
        VG_PATH_DATATYPE_S_32                       =  2
        VG_PATH_DATATYPE_F                          =  3
        VG_PATH_DATATYPE_FORCE_SIZE                 = VG_MAX_ENUM
        
    enum VGPathCapabilities:
        VG_PATH_CAPABILITY_APPEND_FROM              = (1 <<  0)
        VG_PATH_CAPABILITY_APPEND_TO                = (1 <<  1)
        VG_PATH_CAPABILITY_MODIFY                   = (1 <<  2)
        VG_PATH_CAPABILITY_TRANSFORM_FROM           = (1 <<  3)
        VG_PATH_CAPABILITY_TRANSFORM_TO             = (1 <<  4)
        VG_PATH_CAPABILITY_INTERPOLATE_FROM         = (1 <<  5)
        VG_PATH_CAPABILITY_INTERPOLATE_TO           = (1 <<  6)
        VG_PATH_CAPABILITY_PATH_LENGTH              = (1 <<  7)
        VG_PATH_CAPABILITY_POINT_ALONG_PATH         = (1 <<  8)
        VG_PATH_CAPABILITY_TANGENT_ALONG_PATH       = (1 <<  9)
        VG_PATH_CAPABILITY_PATH_BOUNDS              = (1 << 10)
        VG_PATH_CAPABILITY_PATH_TRANSFORMED_BOUNDS  = (1 << 11)
        VG_PATH_CAPABILITY_ALL                      = (1 << 12) - 1

        VG_PATH_CAPABILITIES_FORCE_SIZE             = VG_MAX_ENUM
        
        
    enum VGParamType:
        VG_MATRIX_MODE                              = 0x1100
        VG_FILL_RULE                                = 0x1101
        VG_IMAGE_QUALITY                            = 0x1102
        VG_RENDERING_QUALITY                        = 0x1103
        VG_BLEND_MODE                               = 0x1104
        VG_IMAGE_MODE                               = 0x1105
        VG_SCISSOR_RECTS                            = 0x1106
        VG_COLOR_TRANSFORM                          = 0x1170
        VG_COLOR_TRANSFORM_VALUES                   = 0x1171
        VG_STROKE_LINE_WIDTH                        = 0x1110
        VG_STROKE_CAP_STYLE                         = 0x1111
        VG_STROKE_JOIN_STYLE                        = 0x1112
        VG_STROKE_MITER_LIMIT                       = 0x1113
        VG_STROKE_DASH_PATTERN                      = 0x1114
        VG_STROKE_DASH_PHASE                        = 0x1115
        VG_STROKE_DASH_PHASE_RESET                  = 0x1116
        VG_TILE_FILL_COLOR                          = 0x1120
        VG_CLEAR_COLOR                              = 0x1121
        VG_GLYPH_ORIGIN                             = 0x1122
        VG_MASKING                                  = 0x1130
        VG_SCISSORING                               = 0x1131
        VG_PIXEL_LAYOUT                             = 0x1140
        VG_SCREEN_LAYOUT                            = 0x1141
        VG_FILTER_FORMAT_LINEAR                     = 0x1150
        VG_FILTER_FORMAT_PREMULTIPLIED              = 0x1151
        VG_FILTER_CHANNEL_MASK                      = 0x1152
        VG_MAX_SCISSOR_RECTS                        = 0x1160
        VG_MAX_DASH_COUNT                           = 0x1161
        VG_MAX_KERNEL_SIZE                          = 0x1162
        VG_MAX_SEPARABLE_KERNEL_SIZE                = 0x1163
        VG_MAX_COLOR_RAMP_STOPS                     = 0x1164
        VG_MAX_IMAGE_WIDTH                          = 0x1165
        VG_MAX_IMAGE_HEIGHT                         = 0x1166
        VG_MAX_IMAGE_PIXELS                         = 0x1167
        VG_MAX_IMAGE_BYTES                          = 0x1168
        VG_MAX_FLOAT                                = 0x1169
        VG_MAX_GAUSSIAN_STD_DEVIATION               = 0x116A
        VG_PARAM_TYPE_FORCE_SIZE                    = VG_MAX_ENUM

    
    
    ###function prototypes ###
    VGPath vgCreatePath(VGint pathFormat,
                                VGPathDatatype datatype,
                                VGfloat scale, VGfloat bias,
                                VGint segmentCapacityHint,
                                VGint coordCapacityHint,
                                VGbitfield capabilities)
    void vgClearPath(VGPath path, VGbitfield capabilities)
    void vgDestroyPath(VGPath path)
    void vgRemovePathCapabilities(VGPath path,
                                  VGbitfield capabilities)
    VGbitfield vgGetPathCapabilities(VGPath path)
    void vgAppendPath(VGPath dstPath, VGPath srcPath)
    void vgAppendPathData(VGPath dstPath,
                                  VGint numSegments,
                                  VGubyte * pathSegments,
                                  void * pathData)
    void vgModifyPathCoords(VGPath dstPath, VGint startIndex,
                                    VGint numSegments,
                                    void * pathData)
    void vgTransformPath(VGPath dstPath, VGPath srcPath)
    VGboolean vgInterpolatePath(VGPath dstPath,
                                        VGPath startPath,
                                        VGPath endPath,
                                        VGfloat amount)
    VGfloat vgPathLength(VGPath path,
                                 VGint startSegment, VGint numSegments)
    void vgPointAlongPath(VGPath path,
                                  VGint startSegment, VGint numSegments,
                                  VGfloat distance,
                                  VGfloat * x, VGfloat * y,
                                  VGfloat * tangentX, VGfloat * tangentY)
    void vgPathBounds(VGPath path,
                              VGfloat * minX, VGfloat * minY,
                              VGfloat * width, VGfloat * height)
    void vgPathTransformedBounds(VGPath path,
                                         VGfloat * minX, VGfloat * minY,
                                         VGfloat * width, VGfloat * height)
    void vgDrawPath(VGPath path, VGbitfield paintModes)
    
    void vgClear(VGint x, VGint y, VGint width, VGint height)
    
    void vgSetf (VGParamType type, VGfloat value)
    void vgSeti (VGParamType type, VGint value)
    void vgSetfv(VGParamType type, VGint count,
                         VGfloat * values)
    void vgSetiv(VGParamType type, VGint count,
                         VGint * values)
    

class VGPathSegment(object):
    VG_CLOSE_PATH                               = ( 0 << 1)
    VG_MOVE_TO                                  = ( 1 << 1)
    VG_LINE_TO                                  = ( 2 << 1)
    VG_HLINE_TO                                 = ( 3 << 1)
    VG_VLINE_TO                                 = ( 4 << 1)
    VG_QUAD_TO                                  = ( 5 << 1)
    VG_CUBIC_TO                                 = ( 6 << 1)
    VG_SQUAD_TO                                 = ( 7 << 1)
    VG_SCUBIC_TO                                = ( 8 << 1)
    VG_SCCWARC_TO                               = ( 9 << 1)
    VG_SCWARC_TO                                = (10 << 1)
    VG_LCCWARC_TO                               = (11 << 1)
    VG_LCWARC_TO                                = (12 << 1)

class VGPathAbsRel(object):
    VG_ABSOLUTE                                 = 0
    VG_RELATIVE                                 = 1


#def SetParam(int paramType, value):
#    if isinstance(value, float):
#        vgSetf(<VGParamType>paramType, value)
#    elif isinstance(value, int):
#        vgSeti(<VGParamType>paramType, value)
#    else:
#        raise TypeError("value must be float or int. Got %r instead"%value)

def SetClearColour(VGfloat r, VGfloat g, VGfloat b, VGfloat a):
    cdef VGfloat c[4]
    c[0]=r
    c[1]=g
    c[2]=b
    c[3]=a
    vgSetfv(VG_CLEAR_COLOR, 4, c)
    
def Clear(VGint x, VGint y, VGint width, VGint height):
    vgClear(x, y, width, height)


cdef class Path:
    cdef:
        VGPath _vg_path #handle to the path structure
    
    def __cinit__(self):
        self._vg_path = vgCreatePath(VG_PATH_FORMAT_STANDARD,
                                    VG_PATH_DATATYPE_F,
                                    1.0, 0.0,
                                    4,
                                    3,
                                    VG_PATH_CAPABILITY_ALL)
                                    
    def __dealloc__(self):
        vgDestroyPath(self._vg_path)
        
    def DrawPath(self):
        vgDrawPath(self._vg_path, VG_STROKE_PATH)
        
    def AppendPathData(self, list cmds, list coords):
        cdef:
            VGint N=len(cmds)
            VGubyte * _cmds
            VGfloat * _coords
            unsigned int i
        if len(cmds) != len(coords):
            raise ValueError("Command list must have same length as coordinate list")
        _cmds = <VGubyte*>malloc(sizeof(VGubyte)*N)
        _coords = <VGfloat*>malloc(sizeof(VGfloat)*2*N)
        for i in xrange(N):
            _cmds[i] = cmds[i]
            _coords[2*i] = coords[i][0]
            _coords[2*i+1] = coords[i][1]
        vgAppendPathData(self._vg_path, N, _cmds, <void*>_coords)
        free(_cmds)
        free(_coords)
