# nlohmann_json 3.10.2 is the latest that works properly with qiskit-aer
# https://github.com/Qiskit/qiskit-aer/issues/1742
# https://github.com/Qiskit/qiskit-aer/pull/2283
MODULE_BUILD_DEPS='flexiblas openmpi spdlog muparserx nlohmann_json/3.10.2'
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
