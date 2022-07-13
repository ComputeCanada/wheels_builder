PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/apache/incubator-mxnet"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch $VERSION $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
MODULE_BUILD_DEPS="flexiblas cuda/11.4 nccl cudnn opencv/4.5.5 cmake protobuf/3.19.4"
PRE_BUILD_COMMANDS='
mkdir build && cd build;
cmake ..
	-DUSE_BLAS=FlexiBLAS
	-DBLAS_VENDOR=FlexiBLAS
	-DCMAKE_BUILD_TYPE=Distribution
	-DUSE_JEMALLOC=OFF
	-DBUILD_TESTING=OFF
	-DBUILD_CPP_EXAMPLES=OFF
	-DUSE_CUDA=ON
	-DUSE_NCCL=ON
	-DUSE_CUDNN=ON
	-DMXNET_CUDA_ARCH="6.0;7.0;7.5;8.0"
	-DUSE_DIST_KVSTORE=ON
	-DProtobuf_LIBRARY=$EBROOTPROTOBUF/lib64/libprotobuf.so
	-DCMAKE_VERBOSE_MAKEFILE=1;
make -j 4;
cd ../python;
cp ../build/libmxnet.so mxnet;
'
BDIST_WHEEL_ARGS='--with-cython'
# Fix setup.py to include correct RPATH. Package libmxnet as well.
# Support flexiblas as blas vendor.
PATCHES='mxnet-setup-flexiblas.patch'
