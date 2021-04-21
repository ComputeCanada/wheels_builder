MODULE_BUILD_DEPS="gcc/9.3.0 openmpi/4.0.3 fftw-mpi/3.3.8 scipy-stack/2020b hdf5-mpi/1.10.6"
PYTHON_DEPS="nose numpy six Cython unittest2 scipy sympy mpi4py-fft shenfun"
PRE_DOWNLOAD_COMMANDS="export FFTW_LIBRARY_DIR=$EBROOTFFTW/lib"
PACKAGE_DOWNLOAD_CMD="wget https://github.com/spectralDNS/spectralDNS/archive/1.2.0.tar.gz -O spectralDNS.tar.gz"