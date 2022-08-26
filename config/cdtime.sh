PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/CDAT/cdtime/archive/refs/tags/v${VERSION}.tar.gz"
PACKAGE_DOWNLOAD_CMD="wget -q $PACKAGE_DOWNLOAD_ARGUMENT && echo Saved v${VERSION}.tar.gz"
PYTHON_DEPS="cdat_info requests"
PRE_BUILD_COMMANDS="sed -i -e 's/numpy.distutils.core/setuptools/g' setup.py"
MODULE_RUNTIME_DEPS="libcdms"

