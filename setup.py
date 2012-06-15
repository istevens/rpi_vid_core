import distribute_setup
distribute_setup.use_setuptools()

from setuptools import setup, find_packages
#from distutils.core import setup
from distutils.extension import Extension
#from Cython.Distutils import build_ext

import subprocess, os
from glob import glob

source_folder = "vidcore"

source_files = glob(os.path.join(source_folder, "*.pyx"))

for fname in source_files:
    base, ext = os.path.splitext(fname)
    cname = "%s.c"%base
    if os.path.exists(cname) and \
        os.stat(cname).st_mtime > os.stat(fname).st_mtime:
        continue
    try:
        subprocess.check_call(["cython", fname])
    except subprocess.CalledProcessError:
        os.remove(cname)
    except OSError:
        print(">>> No Cython version found on the system path")

ext_modules = [
	Extension(name='vidcore.bcm',
                    sources=['vidcore/bcm.c'],
                    extra_compile_args=['-DRPI_NO_X'],
                    libraries=['m','bcm_host'],
                    library_dirs=['/opt/vc/lib'],
                    include_dirs=['.','/opt/vc/include']
                    ),
	Extension(name='vidcore.egl',
                    sources=['vidcore/egl.c'],
                    extra_compile_args=['-DRPI_NO_X'],
                    libraries=['GLESv2','EGL','m','bcm_host'],
                    library_dirs=['/opt/vc/lib'],
                    include_dirs=['.','/opt/vc/include']
                    ),
	Extension(name='vidcore.vg',
                    sources=['vidcore/vg.c'],
                    extra_compile_args=['-DRPI_NO_X'],
                    libraries=['m','OpenVG'],
                    library_dirs=['/opt/vc/lib'],
                    include_dirs=['.','/opt/vc/include']
                    )
	]

try:
    proc = subprocess.Popen(['hg','id','-t'], stdout=subprocess.PIPE)
    output, unused_err = proc.communicate()
    retcode = proc.poll()
    ver = "unversioned"
    if not retcode: #hg got the tag no OK
        for ver in output.split():
            if ver.strip()!="tip":
                break
        else:
            ver="untagged"
    open("vidcore/version.py",'wt').write("__version__='%s'\n"%ver)
except OSError:
    pass
execfile("vidcore/version.py")

setup(
  name = 'rpi_vid_core',
  version=__version__,
  description="Core hardware-accelerated graphics libraries for the Raspberry Pi: OpenVG, EGL",
  #cmdclass = {'build_ext': build_ext},
  ext_modules = ext_modules,
  author="Bryan Cole",
  author_email="bryancole.cam@gmail.com",
  url="https://bitbucket.org/bryancole/rpi_vid_core",
  zip_safe=True,
  packages = find_packages()
)

