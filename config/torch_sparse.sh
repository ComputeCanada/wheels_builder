PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION} torch-scatter"
if [[ "$EBVERSIONGENTOO" == "2023" ]]; then
	MODULE_BUILD_DEPS="cuda/12.2 metis-64idx/5.1.0" # Must use 64 bits index module
else
	MODULE_BUILD_DEPS="gcc/9.3.0 cuda/11.7 metis-64idx/5.1.0" # Must use 64 bits index module
fi
PRE_BUILD_COMMANDS="
	export TORCH_CUDA_ARCH_LIST='6.0;7.0;7.5;8.0;8.6;9.0';
	export FORCE_CUDA=1;
	export WITH_METIS=1;
	sed -i -E \"s#'scipy',#'scipy','torch'#\" setup.py;
"
