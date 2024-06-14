PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/pyg-team/pyg-lib"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch ${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION}"
MODULE_BUILD_DEPS="cuda protobuf cudnn abseil"
PRE_BUILD_COMMANDS="
	export TORCH_CUDA_ARCH_LIST='6.0;7.0;7.5;8.0;8.6;9.0';
	export FORCE_CUDA=1;
    export USE_CUDNN=1;
	sed -i \"s#install_requires = \[\]#install_requires = \['torch'\]#\" setup.py;
"
