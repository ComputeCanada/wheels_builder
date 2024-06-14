# could use cuQuantum but a pain to install
MODULE_RUNTIME_DEPS="symengine flexiblas openmpi cuda/12 spdlog muparserx"
PRE_BUILD_COMMANDS='rm -f pyproject.toml'
BDIST_WHEEL_ARGS='
    -DBLA_VENDOR=FlexiBLAS
    -DDISABLE_CONAN=ON
    -DAER_MPI=ON
    -DAER_CUDA_ARCH="6.0;7.0;7.5;8.0;8.6;8.6+PTX"
    -DAER_THRUST_BACKEND=CUDA
    -DCUDA_NVCC_FLAGS="-D_AVX512BF16VLINTRIN_H_INCLUDED -D_AVX512BF16INTRIN_H_INCLUDED"
'
PYTHON_IMPORT_NAME='qiskit.Aer'
