PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION}"
if [[ "$EBVERSIONGENTOO" == "2023" ]]; then
	MODULE_BUILD_DEPS="cuda/12.6"
else
	MODULE_BUILD_DEPS="gcc/9.3.0 cuda/11.7"
fi
PRE_BUILD_COMMANDS="
	export TORCH_CUDA_ARCH_LIST='7.0;8.0;9.0';
	export FORCE_CUDA=1;
	sed -i \"s#install_requires = \[\]#install_requires = \['torch'\]#\" setup.py;
"
