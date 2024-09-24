# Does not support 6.0; Pascal arch not supported!!
PRE_BUILD_COMMANDS="
	export TORCH_CUDA_ARCH_LIST='7.0;7.5;8.0;8.6;9.0';
"
PYTHON_DEPS="torch"
MODULE_BUILD_DEPS="cuda"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/nerfstudio-project/gsplat.git"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --jobs 16 --depth 1 --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
