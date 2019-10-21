MODULE_BUILD_DEPS="gcc openmpi hdf5-mpi netcdf-mpi"
PRE_BUILD_COMMANDS='module load mpi4py; export HDF5_DIR=$EBROOTHDF5; export NETCDF4_DIR=$EBROOTNETCDF'
RPATH_TO_ADD="$EBROOTOPENMPI/lib"

