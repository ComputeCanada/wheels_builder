if [[ "$EBVERSIONGENTOO" != "2023" ]]; then
    MODULE_BUILD_DEPS="sdl2 cmake"
fi
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/mgbellemare/Arcade-Learning-Environment.git"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
PRE_BUILD_COMMANDS="export GITHUB_REF=$VERSION; export CIBUILDWHEEL=$VERSION;" # override sha1 append
