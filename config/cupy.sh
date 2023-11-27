PYTHON_DEPS="optuna"
# TODO: check if cusparselt works
if [[ "$EBVERSIONGENTOO" == "2023" ]]; then
	MODULE_BUILD_DEPS="cuda/12.2 cudnn nccl cutensor/1.7"
else
    MODULE_BUILD_DEPS="gcc/9.3.0 cuda/11.4 cudnn nccl cutensor"
fi
# needed otherwise it does not find libcuda.so
PRE_DOWNLOAD_COMMANDS='export LDFLAGS="-L$EBROOTCUDA/lib64/stubs -L$EBROOTNCCL/lib" ; export CFLAGS="-I$EBROOTNCCL/include/"'
