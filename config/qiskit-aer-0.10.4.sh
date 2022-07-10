#remove pyproject.toml because passing argument to skbuild for CMake
#is not available
PATCHES="qiskit-aer-0.10.4.patch"
MODULE_RUNTIME_DEPS="
    symengine/0.9.0
    flexiblas/3.0.4
    openmpi/4.0.3
"
PYTHON_IMPORT_NAME="qiskit.Aer"
PYTHON_DEPS="cmake"
BDIST_WHEEL_ARGS="--
    -DBLA_VENDOR=FlexiBLAS
    -DAER_MPI=True
    -DDISABLE_CONAN=OFF
    -DSymEngine_DIR=$EBROOTSYMENGINE/lib/cmake/symengine/
"
