PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION}"
MODULE_BUILD_DEPS="cuda/12"
# Only support Ampere and newer architectures
PRE_BUILD_COMMANDS="
    export CUDA_ARCH_LIST='80;86;90';
    export MAX_JOBS=${SLURM_CPUS_PER_TASK-4};
"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/microsoft/DeepSpeed-Kernels.git"
# HEAD is bdb30fdf51bab5053a6a4143823e8cb81d808c2e but it is not a tag yet
PACKAGE_DOWNLOAD_CMD="git clone --recursive $PACKAGE_DOWNLOAD_ARGUMENT $PACKAGE_FOLDER_NAME"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
POST_DOWNLOAD_COMMANDS="tar -zcf $PACKAGE_DOWNLOAD_NAME $PACKAGE_FOLDER_NAME"
PYTHON_IMPORT_NAME="dskernels"