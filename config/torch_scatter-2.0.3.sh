PYTHON_DEPS="torch==1.4.0"
MODULE_BUILD_DEPS="gcc/7.3.0 cuda/10.1"
PRE_BUILD_COMMANDS="export TORCH_CUDA_ARCH_LIST='3.5;3.7;6.0;7.0'; export FORCE_CUDA=1; sed -i 's/install_requires = \[\]/install_requires = \[\"torch==1.4.0\"\]/' setup.py"
