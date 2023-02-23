MODULE_RUNTIME_DEPS='openmpi mpi4py fftw-mpi hdf5-mpi'
PYTHON_DEPS="h5py  mercurial"
PRE_BUILD_COMMANDS='export MPI_PATH=$EBROOTOPENMPI; export FFTW_PATH=$EBROOTFFTW; export FFTW_STATIC=1; export CC=mpicc;'
# pip download runs the setup in order to build the metadata, which requires the paths to be known...
PRE_DOWNLOAD_COMMANDS=$PRE_BUILD_COMMANDS
