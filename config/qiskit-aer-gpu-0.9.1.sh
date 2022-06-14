PACKAGE="qiskit-aer"
PACKAGE_SUFFIX="-gpu"
# setup.py takes package name from QISKIT_AER_PACKAGE_NAME environment
# variable, so:
PRE_BUILD_COMMANDS="export QISKIT_AER_PACKAGE_NAME=qiskit-aer-gpu"
PACKAGE_DOWNLOAD_ARGUMENT="$PACKAGE==$VERSION"
MODULE_RUNTIME_DEPS="
    symengine
    cuda/11.4
    flexiblas/3.0.4
    openmpi/4.0.3
"
PYTHON_IMPORT_NAME=qiskit.Aer
PYTHON_DEPS="cmake"
BDIST_WHEEL_ARGS="--
    -DBLA_VENDOR=FlexiBLAS
    -DAER_THRUST_BACKEND=CUDA
    -DAER_CUDA_ARCH='7.0;7.5;8.0;8.6;8.6+PTX'
    -DAER_MPI=True
    -DDISABLE_CONAN=OFF
    -DSymEngine_DIR=$EBROOTSYMENGINE/lib/cmake/symengine/
"
