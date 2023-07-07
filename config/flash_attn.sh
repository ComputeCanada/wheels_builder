PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION}"
PRE_BUILD_COMMANDS="
	export TORCH_CUDA_ARCH_LIST='6.0;7.0;7.5;8.0;8.6';
"
# torch 2.0.1 uses 11.7, but previous versions uses 11.4
MODULE_BUILD_DEPS="gcc/9.3.0 cmake cuda/11.7"
