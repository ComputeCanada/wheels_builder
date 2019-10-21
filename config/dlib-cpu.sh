MODULE_BUILD_DEPS="gcc/7.3.0 boost imkl"    # it does not work with Intel, and requires Boost
PRE_BUILD_COMMANDS='sed -i -e "s;/opt/intel/mkl/lib/intel64;${MKLROOT}/lib/intel64;g" $(find . -name "*find_blas.*") '
PACKAGE="dlib"
PYTHON_IMPORT_NAME="$PACKAGE"
PACKAGE_FOLDER_NAME="$PACKAGE"
PACKAGE_DOWNLOAD_NAME="$PACKAGE"
PACKAGE_DOWNLOAD_ARGUMENT="$PACKAGE"
PACKAGE_SUFFIX='-cpu'
BDIST_WHEEL_ARGS='--yes CMAKE_SKIP_RPATH'

