PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/hpcaitech/FastFold/archive/refs/tags/${VERSION:?version required}.tar.gz"
MODULE_BUILD_DEPS="cuda/11.4 cudnn"
# Set TORCH_VERSION in your shell to build with a specific version or latest/current by default.
PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION} einops colossalai"
PRE_BUILD_COMMANDS="
	export MAX_JOBS=4;
	export TORCH_CUDA_ARCH_LIST='6.0;7.0;7.5;8.0;8.6';
"
