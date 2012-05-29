


cdef extern from "/opt/vc/include/bcm_host.h":
    ctypedef int int32_t
    ctypedef unsigned short int	uint16_t
    ctypedef unsigned int		uint32_t
    
    ctypedef uint32_t DISPMANX_DISPLAY_HANDLE_T
    ctypedef uint32_t DISPMANX_UPDATE_HANDLE_T
    ctypedef uint32_t DISPMANX_ELEMENT_HANDLE_T
    ctypedef uint32_t DISPMANX_RESOURCE_HANDLE_T
    ctypedef uint32_t DISPMANX_PROTECTION_T
    
    struct tag_VC_RECT_T:
        int32_t x
        int32_t y
        int32_t width
        int32_t height
        
    ctypedef tag_VC_RECT_T VC_RECT_T
        
    ctypedef enum DISPMANX_TRANSFORM_T:
        pass
        
    ctypedef struct DISPMANX_CLAMP_T:
        pass
        
    ctypedef struct VC_DISPMANX_ALPHA_T:
        pass
    
    void bcm_host_init()
    void bcm_host_deinit()
    
    int32_t c_get_display_size "graphics_get_display_size" (uint16_t display_number,
                                      uint32_t *width, uint32_t *height)
    DISPMANX_DISPLAY_HANDLE_T vc_dispmanx_display_open( uint32_t device )
    DISPMANX_UPDATE_HANDLE_T vc_dispmanx_update_start( int32_t priority )
    DISPMANX_ELEMENT_HANDLE_T vc_dispmanx_element_add ( DISPMANX_UPDATE_HANDLE_T update, 
                                                        DISPMANX_DISPLAY_HANDLE_T display,
                                                        int32_t layer, 
                                                        VC_RECT_T *dest_rect, 
                                                        DISPMANX_RESOURCE_HANDLE_T src,
                                                        VC_RECT_T *src_rect, 
                                                        DISPMANX_PROTECTION_T protection, 
                                                        VC_DISPMANX_ALPHA_T *alpha,
                                                        DISPMANX_CLAMP_T *clamp, 
                                                        DISPMANX_TRANSFORM_T transform )
    int vc_dispmanx_update_submit_sync( DISPMANX_UPDATE_HANDLE_T update )


DISPMANX_PROTECTION_NONE = 0


cdef class Rect:
    cdef:
        VC_RECT_T _vc_rect
        
    def __cinit__(self, int32_t x, int32_t y, int32_t width, int32_t height):
        self._vc_rect.x = x
        self._vc_rect.y = y
        self._vc_rect.width = width
        self._vc_rect.height = height
        
    property x:
        def __get__(self):
            return self._vc_rect.x
            
        def __set__(self, int32_t x):
            self._vc_rect.x = x
            
    property y:
        def __get__(self):
            return self._vc_rect.y
            
        def __set__(self, int32_t y):
            self._vc_rect.y = y
            
    property width:
        def __get__(self):
            return self._vc_rect.width
            
        def __set__(self, int32_t width):
            self._vc_rect.width = width
            
    property height:
        def __get__(self):
            return self._vc_rect.height
            
        def __set__(self, int32_t h):
            self._vc_rect.height = h
            
            
cdef class DisplayHandle:
    cdef DISPMANX_DISPLAY_HANDLE_T _handle
    
cdef class UpdateHandle:
    cdef DISPMANX_UPDATE_HANDLE_T _handle
    
cdef class ResourceHandle:
    cdef DISPMANX_RESOURCE_HANDLE_T _handle
    
cdef class ProtectionHandle:
    cdef DISPMANX_PROTECTION_T _handle
    
cdef class ElementHandle:
    cdef DISPMANX_ELEMENT_HANDLE_T _handle
    
    
class BCMDisplayException(Exception):
    pass
    
    
def host_init():
    bcm_host_init()
    
def host_deinit():
    bcm_host_deinit()
    
def graphics_get_display_size(uint16_t number):
    cdef:
        int32_t ret
        uint32_t width, height
        
    ret = c_get_display_size(number, &width, &height)
    if ret < 0:
        raise BCMDisplayException("Failed to get display size")
    return (width, height)

def display_open(uint32_t device):
    cdef:
        DISPMANX_DISPLAY_HANDLE_T disp
    disp = vc_dispmanx_display_open( device )
    D = DisplayHandle()
    D._handle = disp
    return D
    
def update_start(int32_t priority):
    cdef DISPMANX_UPDATE_HANDLE_T hdl
    hdl = vc_dispmanx_update_start( priority )
    U = UpdateHandle()
    U._handle = hdl
    return U
    
def element_add(UpdateHandle update, 
                DisplayHandle display, 
                int32_t layer,
                Rect dest_rect,
                Rect src_rect):
    cdef:
        DISPMANX_ELEMENT_HANDLE_T elem
    elem = vc_dispmanx_element_add (update._handle, 
                                     display._handle,
                                     layer, 
                                     &(dest_rect._vc_rect), 
                                     0, #DISPMANX_RESOURCE_HANDLE_T src,
                                     &(src_rect._vc_rect), 
                                     DISPMANX_PROTECTION_NONE, #DISPMANX_PROTECTION_T protection, 
                                     <VC_DISPMANX_ALPHA_T *>0, #VC_DISPMANX_ALPHA_T *alpha,
                                     <DISPMANX_CLAMP_T *>0, #DISPMANX_CLAMP_T *clamp, 
                                     <DISPMANX_TRANSFORM_T>0) #DISPMANX_TRANSFORM_T transform
    E = ElementHandle()
    E._handle = elem
    return E
    
def update_submit_sync(UpdateHandle update):
    return vc_dispmanx_update_submit_sync( update._handle )
