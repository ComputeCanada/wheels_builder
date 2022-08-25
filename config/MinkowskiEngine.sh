MODULE_BUILD_DEPS="cuda/11.4 flexiblas"
# Use this commit as it contains multiple fix from 0.5.4
PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/NVIDIA/MinkowskiEngine@f9778ad325feb34fc325c235b883421f4cb8fa17"
BDIST_WHEEL_ARGS="--blas_include_dirs=$EBROOTFLEXIBLAS/include/flexiblas --blas_library_dirs=$EBROOTFLEXIBLAS/lib --blas=flexiblas --force_cuda --cuda_home=$CUDA_HOME"
PATCHES="MinkowskiEngine_flexiblas.patch MinkowskiEngine_py310_torch1120.patch"
PRE_BUILD_COMMANDS='
	export TORCH_CUDA_ARCH_LIST="6.0;7.0;7.5;8.0;8.6";
	export MAX_JOBS=4;
'
PYTHON_DEPS="torch pybind11"
UPDATE_REQUIREMENTS="'torch'"
