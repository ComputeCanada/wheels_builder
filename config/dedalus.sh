MODULE_BUILD_DEPS='gcc/13 openmpi/5 mpi4py fftw-mpi hdf5-mpi'
MODULE_RUNTIME_DEPS='gcc openmpi mpi4py'
PYTHON_DEPS="h5py"
PRE_BUILD_COMMANDS='export MPI_PATH=$EBROOTOPENMPI; export FFTW_PATH=$EBROOTFFTWMPI; export FFTW_STATIC=1; export CC=mpicc;'
# pip download runs the setup in order to build the metadata, which requires the paths to be known...
PRE_DOWNLOAD_COMMANDS=$PRE_BUILD_COMMANDS
PRE_TEST_COMMANDS='export OMP_NUM_THREADS=1; export PYTEST_WORKERS=${SLURM_CPUS_PER_TASK-auto};'
PYTHON_TESTS="import dedalus.tests; dedalus.tests.test()"
