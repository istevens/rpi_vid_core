
from libc.stdlib cimport malloc, free


cdef extern from "./esUtil.h":
    ctypedef unsigned char    GLboolean
    ctypedef unsigned int     EGLenum
    ctypedef int              GLint
    ctypedef unsigned int     GLuint
    ctypedef void *EGLNativeWindowType
    ctypedef void *EGLDisplay
    ctypedef void *EGLContext
    ctypedef void *EGLSurface
    ctypedef struct ESContext:
        void *pyctx
        void *userData
        GLint width
        GLint height
        EGLNativeWindowType  hWnd
        EGLDisplay  eglDisplay
        EGLContext  eglContext
        EGLSurface  eglSurface
        void (*drawFunc) #( struct _escontext * )
        void (*keyFunc) #( struct _escontext *, unsigned char, int, int )
        void (*updateFunc) #( struct _escontext *, float deltaTime )
    
    ctypedef void (*drawFunc)(ESContext *)
    
    void esInitContext ( ESContext *esContext )
    GLboolean esCreateWindow ( ESContext *esContext, char *title, 
            GLint width, GLint height, GLuint flags, EGLenum api )
    GLboolean esCreateWindow2 ( ESContext *esContext )
    void esRegisterDrawFunc ( ESContext *esContext, drawFunc user_func )
    void esMainLoop ( ESContext *esContext )
    
cdef extern from "./Hello_Triangle.h":
    int Init(ESContext *esContext)
    void Draw(ESContext *esContext)
    
    
cdef drawFunc this_callback


cdef class Context:
    cdef ESContext *_c_esctx
    cdef public object draw_func
    def __cinit__(self):
        self._c_esctx = <ESContext*>malloc(sizeof(ESContext))
        esInitContext(self._c_esctx)
        self._c_esctx.pyctx = <void*>self
        if self._c_esctx is NULL:
            raise MemoryError("Couldn't assign ESContext memory")

        def on_draw(ctx):
            print "drawing...", ctx
        self.draw_func = on_draw
            
    def __dealloc__(self):
        free(self._c_esctx)
        
    def get_self(self):
        return <object>(self._c_esctx.pyctx)
        
        
def htInit(Context pyctx):
    if not Init(pyctx._c_esctx):
        raise RuntimeError("Failed to initialise ES Context")
        
def htDraw(Context pyctx):
    Draw(pyctx._c_esctx)
        
        
def CreateWindow(Context ctx, char *title, GLint width, GLint height, 
                                        GLuint flags, EGLenum api):
    if esCreateWindow(ctx._c_esctx, title, width, height, flags, api) != 1:
        raise RuntimeError("Failed to create window")
        
def CreateWindow2(Context ctx, char *title, GLint width, GLint height, 
                                        GLuint flags, EGLenum api):
    if esCreateWindow2(ctx._c_esctx) != 1:
        raise RuntimeError("Failed to create window")
    
def RegisterDrawFunc(Context ctx, object func):
    if not callable(func):
        raise TypeError("Second argument must be a callable")
    ctx.draw_func = func
    esRegisterDrawFunc(ctx._c_esctx, _draw)
    
cdef void _draw(ESContext *ctx):
    cdef Context pyctx
    pyctx = <Context>(ctx.pyctx)
    pyctx.draw_func(pyctx)
        
def MainLoop(Context ctx):
    esMainLoop(ctx._c_esctx)
    
    
