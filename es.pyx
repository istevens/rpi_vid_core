
from libc.stdlib cimport malloc, free

cdef extern from "./esUtil.h":
    ctypedef struct ESContext:
        pass
    ctypedef unsigned char    GLboolean
    ctypedef int              GLint
    ctypedef unsigned int     GLuint
    ctypedef void (*drawFunc)(ESContext *)
    
    void esInitContext ( ESContext *esContext )
    GLboolean esCreateWindow ( ESContext *esContext, char *title, GLint width, GLint height, GLuint flags )
    void esRegisterDrawFunc ( ESContext *esContext, drawFunc user_func )
    void esMainLoop ( ESContext *esContext )
    
cdef drawFunc this_callback


cdef class Context:
    cdef ESContext *_c_esctx
    def __cinit__(self):
        self._c_esctx = <ESContext*>malloc(sizeof(ESContext))
        if self._c_esctx is NULL:
            raise MemoryError("Couldn't assign ESContext memory")
            
    def __dealloc__(self):
        free(self._c_esctx)


def InitContext(Context ctx):
    esInitContext(ctx._c_esctx)
        
def CreateWindow(Context ctx, char *title, GLint width, GLint height, GLuint flags):
    if esCreateWindow(ctx._c_esctx, title, width, height, flags) != 1:
        raise RuntimeError("Failed to create window")
    
def RegisterDrawFunc(Context ctx, object func):
    if not callable(func):
        raise TypeError("Second argument must be a callable")
    this_callback = <drawFunc>func
    esRegisterDrawFunc(ctx._c_esctx, draw)
    
cdef void draw(ESContext *ctx):
    pyctx = Context.__new__()
    pyctx._c_esctx = ctx
    (<object>this_callback)(pyctx)
        
def MainLoop(Context ctx):
    esMainLoop(ctx._c_esctx)
    
    
