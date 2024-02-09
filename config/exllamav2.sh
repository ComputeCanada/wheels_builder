PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/turboderp/exllamav2/archive/refs/tags/${VERSION:?version required}.tar.gz"
PRE_BUILD_COMMANDS='
    export TORCH_CUDA_ARCH_LIST="6.0;7.0;7.5;8.0;8.6";
'
PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION}"
MODULE_BUILD_DEPS="cuda/12.2"
