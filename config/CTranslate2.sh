PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/OpenNMT/CTranslate2"
PACKAGE_DOWNLOAD_CMD="git clone --depth 1 --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
POST_DOWNLOAD_COMMANDS="tar -zcf $PACKAGE_DOWNLOAD_NAME $PACKAGE_FOLDER_NAME"
# Build with CUDA, cuDNN, NCCL and MPI for tensor parallel. Enable RUY for quantized models.
# Ensure ISA dispatch for avx512
# Copy shared library into build directory to include it in built wheel
PRE_BUILD_COMMANDS='
	sed -i -e "s/NAMES openblas/NAMES flexiblas/" CMakeLists.txt &&
	cmake -B _build -S . -DCMAKE_INSTALL_PREFIX=$PWD/INST -DOPENMP_RUNTIME=COMP -DWITH_CUDA=ON -DWITH_CUDNN=ON -DCUDA_ARCH_LIST="6.0 7.0 7.5 8.0 8.6 9.0" -DBLA_VENDOR=FlexiBLAS -DWITH_OPENBLAS=ON -DWITH_MKL=OFF -DCMAKE_INCLUDE_PATH=$EBROOTFLEXIBLAS/include/flexiblas -DCMAKE_LIBRARY_PATH=$EBROOTFLEXIBLAS/lib -DWITH_TENSOR_PARALLEL=ON -DENABLE_CPU_DISPATCH=ON -DWITH_RUY=ON &&
	cmake --build _build --parallel $SLURM_CPUS_ON_NODE &&
	cmake --install _build &&
	export CTRANSLATE2_ROOT=$PWD/INST &&
	cd python &&
	python setup.py build_ext &&
	cp -v $CTRANSLATE2_ROOT/lib64/libctranslate2.so.4 build/lib.*/ctranslate2/;
'
MODULE_BUILD_DEPS='openmpi cuda cudnn nccl flexiblas'
PYTHON_IMPORT_NAME="ctranslate2"
RPATH_ADD_ORIGIN="yes" # any value is good
