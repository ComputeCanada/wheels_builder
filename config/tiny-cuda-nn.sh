PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/NVlabs/tiny-cuda-nn"
PACKAGE_DOWNLOAD_CMD="git clone --depth 1 --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf $PACKAGE_DOWNLOAD_NAME $PACKAGE_FOLDER_NAME"

PYTHON_IMPORT_NAME='tinycudann'
PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION}"
MODULE_BUILD_DEPS='cuda/11.7'
PRE_BUILD_COMMANDS='
    export TCNN_CUDA_ARCHITECTURES="60;70;75;80;86";
    cd bindings/torch;
'