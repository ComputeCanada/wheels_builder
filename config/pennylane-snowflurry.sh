MODULE_RUNTIME_DEPS='julia'
PRE_TEST_COMMANDS='export IS_USER_CONFIGURED=True'
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/calculquebec/pennylane-snowflurry"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --jobs 16 --depth 1 --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"