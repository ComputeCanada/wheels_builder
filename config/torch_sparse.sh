PYTHON_DEPS="torch==1.10.0 torch-scatter"
MODULE_BUILD_DEPS="gcc/9.3.0 cuda/11.4"
PRE_BUILD_COMMANDS="export TORCH_CUDA_ARCH_LIST='6.0;7.0;7.5;8.0'; export FORCE_CUDA=1;"
