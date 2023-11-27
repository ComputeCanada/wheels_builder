PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION}"
if [[ "$EBVERSIONGENTOO" == "2023" ]]; then
	MODULE_BUILD_DEPS="cuda/12.2"
else
	MODULE_BUILD_DEPS="gcc/9.3.0 cuda/11.7"
fi
PRE_BUILD_COMMANDS="
	export TORCH_CUDA_ARCH_LIST='6.0;7.0;7.5;8.0;8.6';
	export FORCE_CUDA=1;
	sed -i -e \"s#install_requires = \[\]#install_requires = \['torch'\]#\" setup.py;
"
