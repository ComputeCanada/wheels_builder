MODULE_BUILD_DEPS="arch/avx2 cmake flexiblas openmpi"
PYTHON_DEPS="pybind11 scipy"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/PennyLaneAI/pennylane-lightning/archive/refs/tags/v${VERSION:?version required}.tar.gz"
PRE_BUILD_COMMANDS="
	export PL_BACKEND='lightning_qubit';
	python setup.py build_ext --define='
		ENABLE_NATIVE=OFF;
		ENABLE_BLAS=ON;
		ENABLE_OPENMP=ON;
        ENABLE_MPI=ON;
		BLA_VENDOR=FlexiBLAS;
		ENABLE_AVX=ON;
		ENABLE_AVX2=ON;
		ENABLE_LAPACK=ON'
"
PATCHES='pennylane_lightning-fix_blas.patch'
