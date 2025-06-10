MODULE_BUILD_DEPS="cmake hdf5 fftw boost"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/prism-em/prismatic/archive/refs/tags/v${VERSION:?version required}.tar.gz"
PACKAGE="PyPrismatic"
PACKAGE_SUFFIX="-cpu"
PYTHON_IMPORT_NAME="pyprismatic.core"
PRE_BUILD_COMMANDS="sed -i -e 's/1.2.0/$VERSION/' setup.py"
PYTHON_DEPS='h5py scipy'
