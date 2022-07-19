MODULE_BUILD_DEPS="cuda/11.4"
PYTHON_DEPS="torch"
PRE_BUILD_COMMANDS="sed -i -e 's/\"-arch=compute_50\"//' setup.py; export TORCH_CUDA_ARCH_LIST='6.0;7.0;7.5;8.0'; export MAX_JOBS=2"
PYTHON_IMPORT_NAME="fast_transformers"
