PYTHON_DEPS="numpy~=$NUMPY_DEFAULT_VERSION cython pytest hypothesis wheel"
#PRE_BUILD_COMMANDS="export BLIS_ARCH='generic'"
PRE_BUILD_COMMANDS="export BLIS_ARCH='haswell'"
#PRE_BUILD_COMMANDS="export BLIS_ARCH='skx'"

