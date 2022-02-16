MODULE_BUILD_DEPS="cmake cuda/11.4 hdf5 fftw boost"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/prism-em/prismatic/archive/refs/tags/v$VERSION.tar.gz"
PACKAGE="PyPrismatic"
PACKAGE_SUFFIX="-gpu"
BDIST_WHEEL_ARGS="--enable-gpu"
PYTHON_IMPORT_NAME="pyprismatic.core"
PYTHON_DEPS='h5py'
