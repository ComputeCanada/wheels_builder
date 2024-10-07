# Support CPU and GPU ops.

PACKAGE="dgl"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PYTHON_IMPORT_NAME=$PACKAGE
PACKAGE_FOLDER_NAME=$PACKAGE
MODULE_BUILD_DEPS="cuda/12.2 cmake nccl cudnn protobuf abseil"
PYTHON_DEPS="networkx pandas torch${TORCH_VERSION:+==$TORCH_VERSION}"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/dmlc/dgl"
PACKAGE_DOWNLOAD_CMD="git clone --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf $PACKAGE_DOWNLOAD_NAME $PACKAGE_FOLDER_NAME"
PRE_BUILD_COMMANDS="
	export TORCH_CUDA_ARCH_LIST='6.0;7.0;7.5;8.0;8.6;9.0';
	export CUDAARCHS='60;70;75;80;86;90';
	cmake -S . -B build -DUSE_OPENMP=ON -DUSE_CUDA=ON -DUSE_NCCL=ON -DUSE_SYSTEM_NCCL=ON -DCUDA_ARCH_BIN='60;70;75;80;86;90' -DCUDA_ARCH_NAME=Manual -DBUILD_TYPE=release &&
	cmake --build build/ --parallel ${SLURM_CPUS_PER_TASK:-1} &&
	cd python
"
# libdgl is not found, patch runpath
POST_BUILD_COMMANDS='setrpaths.sh --path $WHEEL_NAME --add_path \$ORIGIN/../..:\$ORIGIN/..:\$ORIGIN/../../torch/lib --any_interpreter'
