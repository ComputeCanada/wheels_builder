MODULE_BUILD_DEPS="arch/avx2 cmake flexiblas"
PYTHON_DEPS="pybind11"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/PennyLaneAI/pennylane-lightning/archive/refs/tags/v${VERSION:?version required}.tar.gz"
PRE_BUILD_COMMANDS="python setup.py build_ext --define='
	ENABLE_NATIVE=OFF;
	ENABLE_BLAS=ON;
	ENABLE_OPENMP=ON;
	BLA_VENDOR=FlexiBLAS;
	ENABLE_AVX=ON;
	ENABLE_AVX2=ON'
"
