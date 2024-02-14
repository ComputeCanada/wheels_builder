MODULE_BUILD_DEPS="cuda/12.2"
PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION}"
PRE_BUILD_COMMANDS="
    export MAMBA_FORCE_BUILD=TRUE;
    export TORCH_CUDA_ARCH_LIST='6.0;7.0;7.5;8.0;8.6';
"
PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/state-spaces/mamba.git@v${VERSION:?version required}"
