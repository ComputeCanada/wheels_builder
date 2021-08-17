MODULE_BUILD_DEPS="gcc/9 cuda/11 cudnn"
PYTHON_DEPS="torch numpy"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/pytorch/audio"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v$VERSION $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
PRE_BUILD_COMMANDS='export LDFLAGS="$LDFLAGS -ltinfo -lgsm "; export BUILD_SOX=1; export BUILD_VERSION=$VERSION; '