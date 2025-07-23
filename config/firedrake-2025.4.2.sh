#NOTE:
# Each Firedrake release is tied to an exact version of PETSc and several other packages.
# Therefore each version of Firedrake requires its own configuration file.
#
# Oliver Stueker
# 2025-07-23
MODULE_RUNTIME_DEPS='openmpi mpi4py symengine libspatialindex petsc/3.23.4'

PYTHON_DEPS="libsupermesh pkgconfig rtree>=1.2"

PATCHES="firedrake-2025.4.2_pyproject_toml.patch"

RPATH_TO_ADD="'\$ORIGIN/../../libsupermesh/lib'"
