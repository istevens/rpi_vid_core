============
RPi_Vid_Core
============

This is a fork of `Bryan Cole's rpi_vid_core project on Bitbucket
<https://bitbucket.org/bryancole/rpi_vid_core/wiki/Home>`_.

Building
========

For my Raspberry Pi, the following worked to build the project::

    > CPATH=/opt/vc/include/interface/vcos/pthreads/:\
    /opt/vc/include/interface/vmcs_host/linux/ \
    python setup.py build_ext --inplace
