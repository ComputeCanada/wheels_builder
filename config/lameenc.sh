PRE_BUILD_COMMANDS='
	sed -i -e "s/libmp3lame.a/libmp3lame.so/" setup.py;
	rm -rf .git;
'
BDIST_WHEEL_ARGS='--libdir=$EBROOTGENTOO/lib64/ --incdir=$EBROOTGENTOO/include/lame/'

PACKAGE="lameenc"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PYTHON_IMPORT_NAME=$PACKAGE
PACKAGE_FOLDER_NAME=$PACKAGE
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/chrisstaite/lameenc"
PACKAGE_DOWNLOAD_CMD="git clone --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf $PACKAGE_DOWNLOAD_NAME $PACKAGE_FOLDER_NAME"
