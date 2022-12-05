PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION} torch-scatter"
MODULE_BUILD_DEPS="gcc/9.3.0 cuda/11.4 metis-64idx/5.1.0" # Must use 64 bits index module
PRE_BUILD_COMMANDS="
	sed -i -e '8i #define CHECK_LT(low, high) AT_ASSERTM(low < high, \"low must be smaller than high\") ' csrc/cpu/utils.h;
	export TORCH_CUDA_ARCH_LIST='6.0;7.0;7.5;8.0;8.6';
	export FORCE_CUDA=1;
	export WITH_METIS=1;
	sed -i -E \"s#'scipy',#'scipy','torch'#\" setup.py;
"
