PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/Qiskit/qiskit-aer/archive/refs/tags/${VERSION:?version required}.tar.gz"
MODULE_BUILD_DEPS='flexiblas openmpi spdlog muparserx cuda/12.9 cuquantum cutensor'
MODULE_RUNTIME_DEPS="openmpi symengine"
PRE_BUILD_COMMANDS='
    rm -f pyproject.toml;
    export QISKIT_AER_PACKAGE_NAME='$PACKAGE';
    export QISKIT_AER_CUDA_MAJOR=12;
    export QISKIT_ADD_CUDA_REQUIREMENTS=false;
    export CUQUANTUM_ROOT=$EBROOTCUQUANTUM;
'
BDIST_WHEEL_ARGS='
    -DBLA_VENDOR=FlexiBLAS
    -DDISABLE_CONAN=ON
    -DAER_MPI=ON
    -DBUILD_TESTS=OFF
    -DAER_CUDA_ARCH="8.0;9.0"
    -DAER_THRUST_BACKEND=CUDA
    -DCUDA_NVCC_FLAGS="-D_AVX512BF16VLINTRIN_H_INCLUDED -D_AVX512BF16INTRIN_H_INCLUDED"
    -DAER_ENABLE_CUQUANTUM=ON
'
PYTHON_IMPORT_NAME='qiskit_aer'
