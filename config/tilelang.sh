MODULE_BUILD_DEPS='cuda/13.2'
PRE_BUILD_COMMANDS='
    export MAX_JOBS=${SLURM_CPUS_PER_TASK:-1};
    export NO_VERSION_LABEL=ON;
    export USE_CUDA=ON;
'
PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/tile-ai/tilelang@v${VERSION:?version required}"
PYTHON_DEPS='z3-solver>=4.13.0'
