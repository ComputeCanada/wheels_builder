PYTHON_DEPS="optuna"
MODULE_BUILD_DEPS="gcc/9.3.0 cuda/11.4 cudnn nccl cutensor"
# needed otherwise it does not find libcuda.so
PRE_DOWNLOAD_COMMANDS='export LDFLAGS="-L$EBROOTCUDA/lib64/stubs -L$EBROOTNCCL/lib" ; export CFLAGS="-I$EBROOTNCCL/include/"'
