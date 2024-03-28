PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION}"
MODULE_BUILD_DEPS="cuda/12"
MODULE_RUNTIME_DEPS="arrow"
PRE_BUILD_COMMANDS="
    export TORCH_CUDA_ARCH_LIST='6.0;7.0;7.5;8.0;8.6;9.0';
    export BUILD_CUDA_EXT=1;
    export MAX_JOBS=8;
    export PYPI_RELEASE=1;
"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/AutoGPTQ/AutoGPTQ/archive/refs/tags/v${VERSION:?version required}.tar.gz"
