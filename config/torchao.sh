MODULE_BUILD_DEPS='cuda/12.6'
PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION} triton"
PRE_BUILD_COMMANDS='
	export USE_CPP=1;
	export USE_SYSTEM_LIBS=1;
	export FORCE_CUDA=1;
	export TORCH_CUDA_ARCH_LIST="8.0;8.6;9.0";
	export MAX_JOBS=2;
	export VERSION_SUFFIX="";
'
PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/pytorch/ao.git@v${VERSION:?version required}"
PATCHES="torchao-forcecuda.patch"
