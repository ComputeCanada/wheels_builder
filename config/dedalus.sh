MODULE_RUNTIME_DEPS='openmpi mpi4py fftw-mpi hdf5-mpi'
PYTHON_DEPS="h5py pytest mercurial"
PRE_BUILD_COMMANDS='export MPI_PATH=$EBROOTOPENMPI; export FFTW_PATH=$EBROOTFFTW; export FFTW_STATIC=1;'
