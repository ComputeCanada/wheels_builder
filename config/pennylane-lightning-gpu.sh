MODULE_BUILD_DEPS="arch/avx2 cmake cuda/11.4 cuquantum flexiblas"
MODULE_RUNTIME_DEPS='cuda/11.4 cuquantum'
PYTHON_DEPS="pybind11"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/PennyLaneAI/pennylane-lightning-gpu/archive/refs/tags/v${VERSION:?version required}.tar.gz"
PRE_BUILD_COMMANDS="
sed -i -E -e '/\s+\"cmake\",/d' -e '/\s+\"ninja\",/d' -e '/\s+\"wheel\",/d' setup.py &&
sed -i -E -e 's/GIT_TAG\s+latest/GIT_TAG v$VERSION/' CMakeLists.txt &&
python setup.py build_ext --cuquantum=$EBROOTCUQUANTUM --define='
	ENABLE_NATIVE=OFF;
	ENABLE_BLAS=ON;
	ENABLE_OPENMP=ON;
	BLA_VENDOR=FlexiBLAS;
	ENABLE_AVX=ON;
	ENABLE_AVX2=ON';
"
UPDATE_REQUIREMENTS="pennylane-lightning==$VERSION pennylane==$VERSION"
