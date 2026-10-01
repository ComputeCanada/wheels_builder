MODULE_BUILD_DEPS="netcdf glew"
PRE_BUILD_COMMANDS="sed -i "s@/usr@$EBROOTGENTOO@" setup.py"
PIP_WHEEL_ARGS='--config-settings=no-libxml=true'
# Must avoid download shenanigans
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/schrodinger/pymol-open-source"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --jobs 16 --depth 1 $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
