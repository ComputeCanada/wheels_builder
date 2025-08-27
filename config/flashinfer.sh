MODULE_BUILD_DEPS='cuda/12.6'
PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION} -U setuptools packaging"
PRE_BUILD_COMMANDS='
	export FLASHINFER_ENABLE_AOT=1;
	export TORCH_CUDA_ARCH_LIST="8.0;9.0";
    export MAX_JOBS=2;
    python -m flashinfer.aot;
'
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/flashinfer-ai/flashinfer.git"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --jobs 16 --depth 1 --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
