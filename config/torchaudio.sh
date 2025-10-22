if [[ "$EBVERSIONGENTOO" == "2023" ]]; then
	MODULE_BUILD_DEPS="cuda/12.6 cudnn/9.5 cmake protobuf abseil"
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
    export TORCH_CUDA_ARCH_LIST="7.0;8.0;9.0";
    export TORIO_USE_FFMPEG_VERSION=4;
    export USE_FFMPEG=ON;
'
RPATH_ADD_ORIGIN="yes"
