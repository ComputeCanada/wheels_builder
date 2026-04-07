MODULE_BUILD_DEPS='cuda/12.9 spdlog'
PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION} setuptools>=77 packaging>=24 ninja requests numpy nvidia-ml-py nvidia-nvshmem-cu12 apache-tvm-ffi>=0.1,<0.2"
PRE_BUILD_COMMANDS='
	export FLASHINFER_CUDA_ARCH_LIST="8.0 9.0";
    export MAX_JOBS=8;
    export FLASHINFER_NVCC_THREADS=2;
    cd flashinfer-jit-cache;
    sed -i -e "s/manylinux_2_28_x86_64/linux_x86_64/" build_backend.py;
'
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/flashinfer-ai/flashinfer.git"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --jobs 16 --depth 1 --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
