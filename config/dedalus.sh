MODULE_RUNTIME_DEPS='openmpi mpi4py fftw-mpi hdf5-mpi'
PYTHON_DEPS="h5py cython==3.0.8"
PRE_BUILD_COMMANDS='export MPI_PATH=$EBROOTOPENMPI; export FFTW_PATH=$EBROOTFFTWMPI; export FFTW_STATIC=1; export CC=mpicc;'
# pip download runs the setup in order to build the metadata, which requires the paths to be known...
PRE_DOWNLOAD_COMMANDS=$PRE_BUILD_COMMANDS
PRE_TEST_COMMANDS='export OMP_NUM_THREADS=1; export PYTEST_WORKERS=${SLURM_CPUS_PER_TASK-auto};'
PYTHON_TESTS="import dedalus.tests; dedalus.tests.test()"
