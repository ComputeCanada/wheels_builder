if [[ "$EBVERSIONGENTOO" == "2023" ]]; then
	MODULE_BUILD_DEPS="cuda/12.2 cudnn"
else
	MODULE_BUILD_DEPS="cuda/11.4 cudnn"
fi
# Set TORCH_VERSION in your shell to build with a specific version or latest/current by default.
PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION}"
PRE_BUILD_COMMANDS="
	export CUDA_EXT=1;
	export MAX_JOBS=4;
	export TORCH_CUDA_ARCH_LIST='6.0;7.0;7.5;8.0;8.6;9.0';
"
