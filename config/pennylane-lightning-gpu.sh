MODULE_BUILD_DEPS="arch/avx2 cmake cuda cuquantum flexiblas"
MODULE_RUNTIME_DEPS='cuda cuquantum'
PYTHON_DEPS="pybind11 scipy"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/PennyLaneAI/pennylane-lightning/archive/refs/tags/v${VERSION:?version required}.tar.gz"
PRE_BUILD_COMMANDS="
	export PL_BACKEND='lightning_gpu';
	export CUQUANTUM_SDK=\$EBROOTCUQUANTUM/lib;
	python setup.py build_ext --define='
	ENABLE_NATIVE=OFF;
	ENABLE_BLAS=ON;
	ENABLE_OPENMP=ON;
	BLA_VENDOR=FlexiBLAS;
	ENABLE_AVX=ON;
	ENABLE_AVX2=ON;
	ENABLE_LAPACK=ON'
"
PATCHES='pennylane_lightning-fix_blas.patch'
PYTHON_IMPORT_NAME='pennylane_lightning'
# `pennylane_lightning.lightning_gpu` requires a device to import correctly.
