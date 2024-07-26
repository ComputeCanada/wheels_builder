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
PYTHON_IMPORT_NAME='qiskit_aer'
