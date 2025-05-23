MODULE_BUILD_DEPS="arch/avx2 cmake cuda cuquantum flexiblas openmpi"
MODULE_RUNTIME_DEPS='cuda cuquantum'
PYTHON_DEPS="pybind11 scipy"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/PennyLaneAI/pennylane-lightning/archive/refs/tags/v${VERSION:?version required}.tar.gz"
PRE_BUILD_COMMANDS="
	export CUQUANTUM_SDK=\$EBROOTCUQUANTUM/lib;
	PL_BACKEND="lightning_gpu" python scripts/configure_pyproject_toml.py;
	export CMAKE_ARGS='-DENABLE_MPI=ON -DENABLE_NATIVE=OFF -DENABLE_BLAS=ON -DENABLE_OPENMP=ON -DBLA_VENDOR=FlexiBLAS -DENABLE_AVX=ON -DENABLE_AVX2=ON -DENABLE_LAPACK=ON';
"
#PATCHES='pennylane_lightning-fix_blas.patch'
PYTHON_IMPORT_NAME='pennylane_lightning'
# `pennylane_lightning.lightning_gpu` requires a device to import correctly.
