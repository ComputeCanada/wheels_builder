MODULE_BUILD_DEPS="cuda/11.4 flexiblas"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/StanfordVL/MinkowskiEngine/archive/master.zip"
PACKAGE_DOWNLOAD_NAME="master.zip"
BDIST_WHEEL_ARGS="--blas_include_dirs=$EBROOTFLEXIBLAS/include/flexiblas --blas_library_dirs=$EBROOTFLEXIBLAS/lib --blas=flexiblas --force_cuda --cuda_home=$CUDA_HOME"
PATCHES="MinkowskiEngine_flexiblas.patch"
PRE_BUILD_COMMANDS='export TORCH_CUDA_ARCH_LIST="6.0;7.0;7.5;8.0"; export MAX_JOBS=4;'
PYTHON_DEPS="torch>=1.10.0"
