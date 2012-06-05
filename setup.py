
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

ext_modules = [
	Extension(name='vidcore.bcm',
                    sources=['vidcore/bcm.pyx'],
                    extra_compile_args=['-DRPI_NO_X'],
                    libraries=['m','bcm_host'],
                    library_dirs=['/opt/vc/lib'],
                    include_dirs=['.','/opt/vc/include']
                    ),
	Extension(name='vidcore.egl',
                    sources=['vidcore/egl.pyx'],
                    extra_compile_args=['-DRPI_NO_X'],
                    libraries=['GLESv2','EGL','m','bcm_host'],
                    library_dirs=['/opt/vc/lib'],
                    include_dirs=['.','/opt/vc/include']
                    ),
	Extension(name='vidcore.vg',
                    sources=['vidcore/vg.pyx'],
                    extra_compile_args=['-DRPI_NO_X'],
                    libraries=['m','OpenVG'],
                    library_dirs=['/opt/vc/lib'],
                    include_dirs=['.','/opt/vc/include']
                    )
	]

setup(
  name = 'Raspberry Pi video core APIs',
  cmdclass = {'build_ext': build_ext},
  ext_modules = ext_modules
)

