MODULE_RUNTIME_DEPS='gcc/13 openmpi mpi4py/4 hdf5-mpi'
PACKAGE_DOWNLOAD_ARGUMENT="git+https://gitlab.com/ArnauMiro/pyqvarsi.git@v${VERSION:?version required}"
PYTHON_DEPS='scipy'
PYTHON_IMPORT_NAME='pyQvarsi'
