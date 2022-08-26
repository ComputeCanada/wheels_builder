PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/pyne/pyne/archive/refs/tags/${VERSION}.tar.gz"
PACKAGE_DOWNLOAD_CMD="wget -q $PACKAGE_DOWNLOAD_ARGUMENT && echo Saved ${VERSION}.tar.gz"
MODULE_BUILD_DEPS="gcc/9.3.0 scipy-stack hdf5 imkl"
PATCHES="pyne-issue1362.patch"
