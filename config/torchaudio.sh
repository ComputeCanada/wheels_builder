if [[ "$EBVERSIONGENTOO" == "2023" ]]; then
	MODULE_BUILD_DEPS="cuda/12.2 cudnn cmake protobuf abseil"
else
    MODULE_BUILD_DEPS="gcc/9 cuda/11.7 cudnn cmake protobuf/3.21.3"
fi
PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION}"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/pytorch/audio"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
PRE_BUILD_COMMANDS='
    export LDFLAGS="$LDFLAGS -ltinfo -lgsm ";
    export BUILD_SOX=1;
    export BUILD_VERSION=$VERSION;
    export TORCH_CUDA_ARCH_LIST="6.0;7.0;7.5;8.0;8.6;9.0";
'
