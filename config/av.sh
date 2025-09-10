# Pythonic bindings for FFmpeg's libraries
# https://github.com/mikeboers/PyAV

RPATH_TO_ADD='$EBROOTFFMPEG/lib'
MODULE_BUILD_DEPS='ffmpeg'

# avoid download non-sense
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/PyAV-Org/PyAV.git"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --depth 1 --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
