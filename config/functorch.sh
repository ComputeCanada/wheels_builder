PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/pytorch/functorch/archive/refs/tags/v${VERSION:?version required}.tar.gz"
PRE_BUILD_COMMANDS="export TORCH_CUDA_ARCH_LIST='6.0;7.0;7.5;8.0;8.6'; export MAX_JOBS=4;"
PYTHON_DEPS='torch==1.12.0'
