#NOTE:
# Each Firedrake release is tied to an exact version of PETSc and several other packages.
# Therefore each version of Firedrake requires its own configuration file.
#
# Oliver Stueker
# 2026-08-17
MODULE_RUNTIME_DEPS='openmpi mpi4py symengine libspatialindex/2.1.0 hdf5-mpi/1.14.6 petsc/3.25.1'
PYTHON_DEPS="libsupermesh pkgconfig rtree>=1.2 petsctools"
#PATCHES="firedrake-2026.4.1_pyproject_toml.patch"
PATCHES="firedrake-2026.4.1_PETSc-3.25.1.patch"
RPATH_TO_ADD="'\$ORIGIN/../../libsupermesh/lib'"

#TEST_COMMAND='python3 -c "from firedrake import *"'
