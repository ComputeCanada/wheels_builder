MODULE_BUILD_DEPS="gcc openmpi fftw mpi4py cython/.0.29.36"
MODULE_RUNTIME_DEPS='gcc openmpi mpi4py'
PRE_DOWNLOAD_COMMANDS="
	export FFTW_LIBRARY_DIR=$EBROOTFFTW/lib;
	export FFTW_INCLUDE_DIR=$EBROOTFFTW/include;
"
PYTHON_IMPORT_NAME="mpi4py_fft"
PYTHON_TESTS="from mpi4py_fft import DistArray; from mpi4py_fft.pencil import Pencil, Subcomm"
