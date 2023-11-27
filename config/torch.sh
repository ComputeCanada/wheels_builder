PYTHON_DEPS="ninja pyyaml"

if [[ "$EBVERSIONGENTOO" == "2023" ]]; then
	MODULE_BUILD_DEPS="gcc openmpi flexiblas cmake fftw eigen protobuf abseil flatbuffers opencv cuda/12 cusparselt cudnn nccl magma"
else
	# 11.7 and up is required for flash attention
	MODULE_BUILD_DEPS="gcc cuda/11.7 openmpi magma nccl cudnn ffmpeg cmake flexiblas/3.0.4 eigen protobuf opencv fftw"
fi
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/pytorch/pytorch.git"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --jobs 16 --depth 1 --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
PRE_BUILD_COMMANDS='
	pip install -r requirements.txt;

	export PYTORCH_BUILD_VERSION=$VERSION;
	export PYTORCH_BUILD_NUMBER=0;

	export CMAKE_LIBRARY_PATH=$EBROOTFLEXIBLAS/lib:$EBROOTCUDACORE/extras/CUPTI/lib64:$EBROOTGENTOO/lib64:$EBROOTGENTOO/lib:$CMAKE_LIBRARY_PATH;
	export CMAKE_INCLUDE_PATH="$EBROOTFLEXIBLAS/include/flexiblas:$EBROOTGENTOO/include:$CMAKE_INCLUDE_PATH";
	export CMAKE_PREFIX_PATH=$VIRTUALENV/lib/python${EBVERSIONPYTHON::3}/site-packages:$EBROOTFLEXIBLAS/include/flexiblas:$EBROOTFLEXIBLAS/lib:$EBROOTCUDNN/lib64:$EBROOTNCCL/lib:$EBROOTFFTW/lib:$EBROOTEIGEN/include:$EBROOTEIGEN/lib:$CMAKE_PREFIX_PATH;
	export LIBRARY_PATH=$EBROOTCUDACORE/extras/CUPTI/lib64:$LIBRARY_PATH;

	export MAX_JOBS=4;
	export DEBUG=OFF;
	export BUILD_TEST=OFF;
	export INSTALL_TEST=OFF;
	export TORCH_CUDA_ARCH_LIST="6.0;7.0;7.5;8.0;8.6";
	export NO_CUDA=OFF;
	export MAGMA_HOME=$EBROOTMAGMA;

	export USE_CUDNN=ON;
	export CUDNN_LIB_DIR=$EBROOTCUDNN/lib64;
	export CUDNN_INCLUDE_DIR=$EBROOTCUDNN/include;
	export CUDNN_LIBRARY=$EBROOTCUDNN/lib64/libcudnn.so;
	export CUDNN_LIBRARY_PATH=$EBROOTCUDNN/lib64/libcudnn.so;

	export USE_SYSTEM_NCCL=ON;
	export NCCL_ROOT=$EBROOTNCCL;
	export NCCL_LIB_DIR=$EBROOTNCCL/lib;
	export NCCL_INCLUDE_DIR=$EBROOTNCCL/include;

	export USE_PROTOBUF_SHARED_LIBS=ON;
	export BUILD_CUSTOM_PROTOBUF=OFF;
	export USE_SYSTEM_EIGEN_INSTALL=ON;

	export USE_OPENCV=ON;
	export USE_FFMPEG=ON;
	export USE_ZSTD=ON;
	export USE_IBVERBS=ON;
	export USE_MPI=ON;

	export BLAS=FlexiBLAS;
	export USE_BLAS=ON;
	export USE_LAPACK=ON;

	export BUILD_FUNCTORCH=ON;
	export BUILD_NVFUSER=ON;
	export USE_FLASH_ATTENTION=ON;
	export USE_MEM_EFF_ATTENTION=ON;

	# export USE_TENSORRT=ON;
	export USE_CUSPARSELT=ON;

	export CMAKE_ARGS="-DONNX_USE_PROTOBUF_SHARED_LIBS=ON"
'
