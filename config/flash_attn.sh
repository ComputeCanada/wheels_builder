PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION}"
PRE_BUILD_COMMANDS="
	export TORCH_CUDA_ARCH_LIST='6.0;7.0;7.5;8.0;8.6;9.0';
	export FLASH_ATTENTION_FORCE_BUILD=TRUE;
	export FLASH_ATTN_CUDA_ARCHS=$TORCH_CUDA_ARCH_LIST;
	export MAX_JOBS=2;
"
if [[ "$EBVERSIONGENTOO" == "2023" ]]; then
	MODULE_BUILD_DEPS="gcc cmake cuda/12.2"
else
	# torch 2.0.1 uses 11.7, but previous versions uses 11.4
	if [[ "$TORCH_VERSION" =~ "2." ]]; then
		MODULE_BUILD_DEPS="gcc/9.3.0 cmake cuda/11.7"
	else
		MODULE_BUILD_DEPS="gcc/9.3.0 cmake cuda/11.4"
	fi
fi
PYTHON_TESTS="from flash_attn import flash_attn_qkvpacked_func, flash_attn_func"
