MODULE_BUILD_DEPS='cuda/13 cudnn'
PRE_BUILD_COMMANDS='
    export MAX_JOBS=${SLURM_CPUS_PER_TASK:-1};
    export NO_VERSION_LABEL=ON;
    export USE_CUDA=ON;
'
PIP_WHEEL_ARGS='--config-settings=wheel.py-api="cp39"'
PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/tile-ai/tilelang@v${VERSION:?version required}"
PYTHON_DEPS='z3-solver>=4.13.0,<5'
