PYTHON_DEPS="fastrlock"
MODULE_BUILD_DEPS="cuda/12.2 cudnn/8.9 nccl cutensor cython/.0.29.36"

# required at runtime, see https://docs.cupy.dev/en/latest/install.html#cupy-always-raises-nvrtc-error-compilation-6
MODULE_RUNTIME_DEPS='cuda/12'

# needed otherwise it does not find libcuda.so
PRE_DOWNLOAD_COMMANDS='export LDFLAGS="-L$EBROOTCUDA/lib64/stubs -L$EBROOTNCCL/lib" ; export CFLAGS="-I$EBROOTNCCL/include/"'
PRE_BUILD_COMMANDS='
    export CUPY_NUM_BUILD_JOBS=${SLURM_CPUS_PER_TASK:-1};
    export CUPY_NUM_NVCC_THREADS=$((${SLURM_CPUS_PER_TASK:-2}/2));

    for arch in 60 70 75 80 86 90; do
    	export CUPY_CUDA_GENCODE="${CUPY_CUDA_GENCODE}arch=compute_${arch},code=sm_${arch};";
    done;
'

# Since v13, CUPY soft links to libnvrtc.so.12, which fails to load on the systems.
# Patch the wheel to need libnvrtc.so.12 explicitly...
POST_BUILD_COMMANDS='
    unzip $WHEEL_NAME cupy_backends/cuda/_softlink$(python3-config --extension-suffix) &&
    patchelf --add-needed libnvrtc.so.12 cupy_backends/cuda/_softlink$(python3-config --extension-suffix) &&
    zip $WHEEL_NAME cupy_backends/cuda/_softlink$(python3-config --extension-suffix);
'
