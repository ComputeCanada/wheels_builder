TORCH_VERSION=1.12.0
PYTHON_DEPS="torch==$TORCH_VERSION"
MODULE_BUILD_DEPS="gcc/9.3.0 cuda/11.4"
PRE_BUILD_COMMANDS="
	export TORCH_CUDA_ARCH_LIST='6.0;7.0;7.5;8.0;8.6';
	export FORCE_CUDA=1;
	sed -i -e \"s#install_requires = \[\]#install_requires = \['torch==$TORCH_VERSION'\]#\" \
	       -e \"s#'$VERSION'#'$VERSION+torch${TORCH_VERSION//./}'#\" setup.py;
"
