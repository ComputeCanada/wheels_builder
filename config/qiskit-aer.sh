MODULE_BUILD_DEPS="scipy-stack" #for dateutil
MODULE_RUNTIME_DEPS="
    symengine/0.9.0
    flexiblas/3.0.4
    openmpi/4.0.3
    cuda/11.4
"
PYTHON_DEPS="cmake"
PRE_BUILD_COMMANDS="
    export CMAKE_ARGS=\"
        -DBLA_VENDOR=FlexiBLAS
        -DAER_THRUST_BACKEND=CUDA
        -DAER_CUDA_ARCH='6.0;7.0;7.5;8.0;8.6;8.6+PTX'
        -DAER_MPI=True
        -DDISABLE_CONAN=OFF
        -DSymEngine_DIR=$EBROOTSYMENGINE/lib/cmake/symengine/
    \"
"
