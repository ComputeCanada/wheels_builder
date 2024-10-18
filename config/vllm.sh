# Use GH sources, https://github.com/vllm-project/vllm/issues/1922
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/vllm-project/vllm"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --jobs 16 --depth 1 --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"

MODULE_RUNTIME_DEPS='arrow'
MODULE_BUILD_DEPS='cuda protobuf abseil nccl'
PYTHON_DEPS='torch==2.4.1'
# nvcc uses os.cpu_count() hardcoded threads which returns 16
PRE_BUILD_COMMANDS='
	export SETUPTOOLS_SCM_PRETEND_VERSION=${VERSION:?version required};
	export TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6;9.0";
	export MAX_JOBS=8;
	export NVCC_THREADS=2;
	sed -i -e "0,/MAIN_CUDA_VERSION/{s/MAIN_CUDA_VERSION.*/MAIN_CUDA_VERSION=\"$EBVERSIONCUDA\"/}" setup.py;
	sed -i -e "s/torchvision\s*==\s*0.19/torchvision~=0.19/" -e "s/2.4.0/2.4.1/" -e "s/cupy-cuda12x/cupy/" -e "/vllm-nccl-.*/d" -e "/^cmake/d" -e "$ a triton" requirements*.txt;
	rm -f requirements-build.txt pyproject.toml;
'
PYTHON_TESTS='from vllm._C import *'
