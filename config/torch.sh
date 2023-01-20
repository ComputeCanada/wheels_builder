PYTHON_DEPS="numpy>=1.21.2 ninja pyyaml"
MODULE_BUILD_DEPS="gcc/9.3.0 cuda/11.4 openmpi magma nccl cudnn ffmpeg cmake flexiblas/3.0.4 eigen protobuf/3.19.4 opencv"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/pytorch/pytorch.git"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --jobs 16 --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
PRE_BUILD_COMMANDS='
	pip install -r requirements.txt;

	export PYTORCH_BUILD_VERSION=$VERSION;
	export PYTORCH_BUILD_NUMBER=0;

	export CMAKE_LIBRARY_PATH="$EBROOTFLEXIBLAS/lib:$EBROOTONEMINDNN/lib64:$CMAKE_LIBRARY_PATH";
	export CMAKE_INCLUDE_PATH="$EBROOTFLEXIBLAS/include/flexiblas:$EBROOTONEMINDNN/include:$CMAKE_INCLUDE_PATH";
	export CMAKE_PREFIX_PATH=$VIRTUALENV/lib/python${EBVERSIONPYTHON::3}/site-packages:$EBROOTFLEXIBLAS/include/flexiblas:$EBROOTFLEXIBLAS/lib:$EBROOTCUDNN/lib64:$EBROOTNCCL/lib:$EBROOTFFTW/lib:$EBROOTEIGEN/include:$EBROOTEIGEN/lib:$EBROOTGENTO/lib64:$EBROOTGENTO/include:$CMAKE_PREFIX_PATH;

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

	export BLAS=FlexiBLAS;
	export USE_BLAS=ON;
	export USE_LAPACK=ON;
'