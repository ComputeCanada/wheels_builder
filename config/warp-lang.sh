MODULE_BUILD_DEPS='cuda/12 git-lfs'
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/NVIDIA/warp"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --jobs 16 --depth 1 --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
PRE_BUILD_COMMANDS='
	python build_lib.py --mode release --fast_math --verbose --no_build_llvm;
'
POST_BUILD_COMMANDS='wheel tags --remove --platform-tag=linux_x86_64 $WHEEL_NAME && WHEEL_NAME=$(ls *.whl)'
PYTHON_IMPORT_NAME='warp'
