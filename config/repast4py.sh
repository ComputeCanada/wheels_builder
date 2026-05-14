MODULE_BUILD_DEPS='gcc openmpi'
MODULE_RUNTIME_DEPS="gcc openmpi mpi4py"
PRE_DOWNLOAD_COMMANDS='
    export CC=mpicc;
    export CXX=mpicxx;
'
