PYTHON_DEPS="torch==1.9.0 torch-scatter"
MODULE_BUILD_DEPS="gcc/8.4.0 cuda/10.2"
PRE_BUILD_COMMANDS="export TORCH_CUDA_ARCH_LIST='3.5;3.7;6.0;7.0;7.5'; export FORCE_CUDA=1;"
