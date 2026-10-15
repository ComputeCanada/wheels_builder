# Use 755381a as it fixes some important issues in place of 0.17.2
PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/Qiskit/qiskit-aer.git@755381a"
MODULE_BUILD_DEPS='flexiblas openmpi spdlog muparserx'
MODULE_RUNTIME_DEPS="symengine"
PRE_BUILD_COMMANDS='
    rm -f pyproject.toml;
    export QISKIT_AER_PACKAGE_NAME='$PACKAGE';
'
BDIST_WHEEL_ARGS='
    -DBLA_VENDOR=FlexiBLAS
    -DDISABLE_CONAN=ON
    -DAER_MPI=ON
    -DBUILD_TESTS=OFF
'
# PYTHON_IMPORT_NAME='qiskit_aer'
PYTHON_TESTS='from qiskit_aer import AerSimulator'
