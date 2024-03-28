PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION}"
MODULE_BUILD_DEPS="cuda/12"
MODULE_RUNTIME_DEPS="arrow"
PRE_BUILD_COMMANDS="
    export TORCH_CUDA_ARCH_LIST='6.0;7.0;7.5;8.0;8.6;9.0';
    export MAX_JOBS=${SLURM_CPUS_PER_TASK-4};
    export PYPI_BUILD=1;
"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/casper-hansen/AutoAWQ/archive/refs/tags/v${VERSION:?version required}.tar.gz"
