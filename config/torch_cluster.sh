PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION}"
MODULE_BUILD_DEPS="gcc/9.3.0 cuda/11.7"
PRE_BUILD_COMMANDS="
	export TORCH_CUDA_ARCH_LIST='6.0;7.0;7.5;8.0;8.6';
	export FORCE_CUDA=1;
	sed -i \"s#install_requires = \[\]#install_requires = \['torch'\]#\" setup.py;
"
