TORCH_VERSION=1.12.0
PYTHON_DEPS="torch==$TORCH_VERSION torch-scatter"
MODULE_BUILD_DEPS="gcc/9.3.0 cuda/11.4 metis-64idx/5.1.0" # Must use 64 bits index module
PRE_BUILD_COMMANDS="
	export TORCH_CUDA_ARCH_LIST='6.0;7.0;7.5;8.0;8.6';
	export FORCE_CUDA=1;
	export WITH_METIS=1;
	sed -i -E \"s#'scipy',#'scipy','torch==$TORCH_VERSION']#' setup.py;
"
