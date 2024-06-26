# Support CPU and GPU ops.

PACKAGE="dgl"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PYTHON_IMPORT_NAME=$PACKAGE
PACKAGE_FOLDER_NAME=$PACKAGE
MODULE_BUILD_DEPS="cmake nccl cudnn protobuf abseil"
if [[ "$EBVERSIONGENTOO" == "2023" ]]; then
	MODULE_BUILD_DEPS="cuda/12.2 $MODULE_BUILD_DEPS"
else
	MODULE_BUILD_DEPS="cuda/11.7 $MODULE_BUILD_DEPS "
fi
PYTHON_DEPS="networkx pandas torch${TORCH_VERSION:+==$TORCH_VERSION}"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/dmlc/dgl"
PACKAGE_DOWNLOAD_CMD="git clone --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf $PACKAGE_DOWNLOAD_NAME $PACKAGE_FOLDER_NAME"
PRE_BUILD_COMMANDS="
	mkdir build &&
	cd build &&
	export TORCH_CUDA_ARCH_LIST='6.0;7.0;7.5;8.0;8.6;9.0' &&
	cmake -DUSE_OPENMP=ON -DUSE_CUDA=ON -DUSE_NCCL=ON -DUSE_SYSTEM_NCCL=ON -DCUDA_ARCH_BIN='60;70;75;80;86;90' -DCUDA_ARCH_NAME=Manual .. &&
	make -j 4 &&
	cd ../python
"
# libdgl is not found, patch runpath
POST_BUILD_COMMANDS='setrpaths.sh --path $WHEEL_NAME --add_path \$ORIGIN/../..:\$ORIGIN/..:\$ORIGIN/../../torch/lib --any_interpreter'
