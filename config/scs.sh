MODULE_BUILD_DEPS="flexiblas"
PRE_BUILD_COMMANDS='
        sed -i -e "s/openblas/flexiblas/" meson.build;
'
PIP_WHEEL_ARGS='-Csetup-args=-Duse_openmp=true'

PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/bodono/scs-python.git"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --jobs 16 --depth 1 --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch ${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
