#FBGEMM GPU is the python gpu kernels while FBGEMM is a CPU library
MODULE_BUILD_DEPS='cmake protobuf cuda/11.7 cudnn'
PYTHON_DEPS="scikit-build ninja jinja2 torch${TORCH_VERSION:+==$TORCH_VERSION} tabulate setuptools-git-versioning"
PRE_BUILD_COMMANDS='
	export CUDNN_LIBRARY=$EBROOTCUDNN/lib;
	export CUDNN_INCLUDE_DIR=$EBROOTCUDNN/include;
	export CMAKE_BUILD_PARALLEL_LEVEL=4;
	cd fbgemm_gpu;
	sed -i -e "s/__version__.*/__version__ = \"$VERSION\"/" version.py;
'
BDIST_WHEEL_ARGS="-DNVML_LIB_PATH=\$CUDA_HOME/lib64/stubs/libnvidia-ml.so -DTORCH_CUDA_ARCH_LIST='6.0;7.0;7.5;8.0;8.6'"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/pytorch/FBGEMM"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
RPATH_TO_ADD="'\$ORIGIN/../torch/lib'"
