# 7e690c2444e5905dbf02816c552d397fc3679ab8 matches v0.0.6
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/fastlmm/fastlmmclib.git"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --jobs 16 --depth 1 --recursive $PACKAGE_DOWNLOAD_ARGUMENT $PACKAGE_FOLDER_NAME && cd fastlmmclib && git checkout 7e690c2444e5905dbf02816c552d397fc3679ab8"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"