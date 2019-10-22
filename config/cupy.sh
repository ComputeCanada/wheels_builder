
PYTHON_DEPS="numpy fastrlock"
MODULE_BUILD_DEPS="gcc/7.3.0 cuda/10 cudnn nccl"
# needed otherwise it does not find libcuda.so
PRE_DOWNLOAD_COMMANDS='export LDFLAGS="-L$EBROOTCUDA/lib64/stubs -L$EBROOTNCCL/lib" ; export CFLAGS="-I$EBROOTNCCL/include/"'
# libnvrtc must find at runtime libnvrtc-builtins, either patch libnvrtc runpath or add DT_NEEDED
current_py_version=${EBVERSIONPYTHON::-2}
current_nvrtc_lib="cupy/cuda/nvrtc.cpython-${current_py_version//.}m-x86_64-linux-gnu.so"
PATCH_WHEEL_COMMANDS="unzip \$ARCHNAME $current_nvrtc_lib && patchelf --add-needed libnvrtc-builtins.so $current_nvrtc_lib && zip \$ARCHNAME $current_nvrtc_lib"
POST_BUILD_COMMANDS=${PATCH_WHEEL_COMMANDS//ARCHNAME/WHEEL_NAME}

